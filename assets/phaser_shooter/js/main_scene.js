class MainScene extends Phaser.Scene {
    constructor() {
        super({ key: 'MainScene' });
    }

    preload() {
        const graphics = this.make.graphics({ x: 0, y: 0, add: false });
        graphics.fillStyle(0xffffff, 1);
        graphics.beginPath();
        graphics.moveTo(30, 15);
        graphics.lineTo(0, 0);
        graphics.lineTo(5, 15);
        graphics.lineTo(0, 30);
        graphics.closePath();
        graphics.fillPath();
        graphics.generateTexture('player', 30, 30);

        const debrisGraphics = this.make.graphics({ x: 0, y: 0, add: false });
        debrisGraphics.fillStyle(0xffffff, 1);
        debrisGraphics.fillRect(0, 0, 8, 8);
        debrisGraphics.generateTexture('debris', 8, 8);

        const sparkGraphics = this.make.graphics({ x: 0, y: 0, add: false });
        sparkGraphics.fillStyle(0xffffff, 1);
        sparkGraphics.fillRect(0, 0, 16, 2);
        sparkGraphics.generateTexture('spark', 16, 2);
    }

    create() {
        const urlParams = new URLSearchParams(window.location.search);
        const tc = urlParams.get('trailColor');
        this.trailColor = tc ? parseInt(tc, 10) : 0xffffff;
        
        this.epicVFX = urlParams.get('epicVFX') === 'true';
        this.comboVFX = urlParams.get('comboVFX') === 'true';
        this.speedBoost = urlParams.get('speedBoost') === 'true';
        this.longTrail = urlParams.get('longTrail') === 'true';
        this.glitchMode = urlParams.get('glitch') === 'true'; // GLITCH MECHANIC
        this.gameMode = urlParams.get('mode') || 'fast'; // fast, survival, sandbox
        this.bgmMode = urlParams.get('bgm') || 'chiptune';

        this.lives = 5;
        this.isOverdrive = false;
        this.currentBPM = 120;

        const width = this.scale.width;
        const height = this.scale.height;

        this.score = 0;
        this.combo = 1;
        this.timeElapsed = 0.0;
        this.beatIndex = 0;
        this.gameState = 'init'; 
        
        if (this.cameras.main.postFX) {
            this.cameras.main.postFX.addBloom(0xffffff, 1.5, 1.5, 1.0, 1.5);
            this.cameras.main.postFX.addVignette(0.5, 0.5, 0.8, 0.4);
        }

        this.stars = [];
        this.starGraphics = this.add.graphics().setDepth(0);
        for(let i=0; i<100; i++) {
            this.stars.push({
                x: Phaser.Math.Between(0, width),
                y: Phaser.Math.Between(0, height),
                z: Phaser.Math.FloatBetween(0.1, 1.0)
            });
        }

        const isMobile = width < 600;
        this.lastHUDTime = 0;

        this.trailHistory = [];
        this.trailGraphics = this.add.graphics({ x: 0, y: 0 }).setDepth(5).setBlendMode(Phaser.BlendModes.ADD);

        this.player = this.physics.add.sprite(width / 2, height / 2 + 100, 'player');
        this.player.setCollideWorldBounds(true);
        this.player.setDamping(true);
        this.player.setDrag(0.05); 
        this.player.setMaxVelocity(1200);
        this.player.setDepth(10);
        this.player.setBlendMode(Phaser.BlendModes.ADD);
        this.player.setVisible(false);
        this.player.body.enable = false;

        this.idleTween = this.tweens.add({
            targets: this.player,
            scaleX: 1.1,
            scaleY: 0.9,
            duration: 1000,
            yoyo: true,
            repeat: -1,
            ease: 'Sine.inOut'
        });
        
        this.targetPoint = new Phaser.Math.Vector2(width / 2, height / 2 + 100);
        this.targets = this.physics.add.group();
        this.physics.add.overlap(this.player, this.targets, this.hitTarget, null, this);

        this.startOverlay = this.add.rectangle(0, 0, width, height, 0x000000, 0.8).setOrigin(0).setDepth(200);
        this.startText = this.add.text(width / 2, height / 2, 'CLICK TO START', {
            fontFamily: '"Press Start 2P", monospace',
            fontSize: isMobile ? '18px' : '32px',
            color: '#ffffff',
            shadow: { offsetX: 0, offsetY: 0, color: '#ffffff', blur: 20, stroke: true, fill: true }
        }).setOrigin(0.5).setDepth(201);
        
        this.tweens.add({
            targets: this.startText,
            alpha: 0.2,
            duration: 800,
            yoyo: true,
            repeat: -1
        });

        // Initialize Native WebAudio securely upon first user gesture
        this.input.once('pointerdown', () => {
            if (window.sfx) {
                window.sfx.init();
            }
            
            this.startText.destroy();
            this.startOverlay.destroy();
            this.player.setVisible(true);
            this.player.body.enable = true;
            this.startCountdown();
        });

        this.input.on('pointerdown', (pointer) => {
            if (this.gameState !== 'playing') return;

            this.targetPoint.x = pointer.worldX;
            this.targetPoint.y = pointer.worldY;
            
            this.createDashRipple(this.player.x, this.player.y);
            this.createClickEffect(this.targetPoint.x, this.targetPoint.y);
            
            if (window.soundDash) window.soundDash();
            
            const angle = Phaser.Math.Angle.Between(this.player.x, this.player.y, this.targetPoint.x, this.targetPoint.y);
            const speed = this.speedBoost ? 3000 : 1500; 
            this.physics.velocityFromRotation(angle, speed, this.player.body.velocity);
            
            if (this.clickTween) this.clickTween.stop();
            if (this.idleTween) this.idleTween.pause();
            
            this.clickTween = this.tweens.add({
                targets: this.player,
                scaleX: 1.5,
                scaleY: 0.5,
                duration: 150,
                yoyo: true,
                ease: 'Quad.out',
                onComplete: () => {
                    if (this.idleTween) this.idleTween.resume();
                }
            });
        });

        // --- NOTIFY FLUTTER THAT PHASER IS READY ---
        this.time.delayedCall(500, () => {
            window.parent.postMessage(JSON.stringify({ type: 'READY' }), "*");
        });
    }

    startCountdown() {
        this.gameState = 'countdown';
        const width = this.scale.width;
        const height = this.scale.height;

        const countText = this.add.text(width / 2, height / 2, '', {
            fontFamily: '"Press Start 2P", monospace',
            fontSize: '80px',
            color: '#ffffff',
            shadow: { offsetX: 0, offsetY: 0, color: '#ffffff', blur: 30, stroke: true, fill: true }
        }).setOrigin(0.5).setDepth(201);
        countText.setBlendMode(Phaser.BlendModes.ADD);

        const sequence = ['3', '2', '1', 'AYOO!!'];
        
        for (let i = 0; i < sequence.length; i++) {
            this.time.delayedCall(i * 1000, () => {
                countText.setText(sequence[i]);
                if(window.soundBlip) window.soundBlip();
                this.tweens.add({
                    targets: countText,
                    scale: { from: 1.5, to: 1 },
                    alpha: { from: 1, to: 0 },
                    duration: 900,
                    ease: 'Cubic.out'
                });
                
                if (i === sequence.length - 1) {
                    this.time.delayedCall(500, () => {
                        countText.destroy();
                        this.gameState = 'playing';
                        if(window.soundGo) window.soundGo();
                        this.startRhythmLoop();
                        this.sendHUDUpdate();
                    });
                }
            });
        }
    }

    triggerGameOver() {
        if (this.gameState === 'gameover') return;
        this.gameState = 'gameover';
        
        const width = this.scale.width;
        const height = this.scale.height;

        const overlay = this.add.rectangle(0, 0, width, height, 0xff0000, 0.4).setOrigin(0).setDepth(200);
        overlay.setBlendMode(Phaser.BlendModes.ADD);

        const gameOverText = this.add.text(width / 2, height / 2, 'GAME OVER', {
            fontFamily: '"Press Start 2P", monospace',
            fontSize: '48px',
            color: '#ffffff',
            shadow: { offsetX: 0, offsetY: 0, color: '#ff0000', blur: 20, stroke: true, fill: true }
        }).setOrigin(0.5).setDepth(201);
        
        this.tweens.add({
            targets: gameOverText,
            scale: { from: 0.5, to: 1 },
            duration: 500,
            ease: 'Back.out'
        });

        this.time.delayedCall(2000, () => {
            window.parent.postMessage(JSON.stringify({ 
                type: 'GAMEOVER', 
                score: this.score 
            }), "*");
        });
    }

    sendHUDUpdate() {
        window.parent.postMessage(JSON.stringify({
            type: 'HUD',
            score: this.score,
            time: this.timeElapsed.toFixed(1),
            lives: this.lives,
            combo: this.combo
        }), "*");
    }

    update(time, delta) {
        if (this.gameState === 'playing' && this.gameMode === 'fast') {
            this.timeElapsed += delta / 1000;
            
            if (time - this.lastHUDTime > 100) {
                this.sendHUDUpdate();
                this.lastHUDTime = time;
            }

            if (this.timeElapsed >= 60.0) { // 60 Detik FAST MODE
                this.triggerGameOver();
            }
        }
        
        if (this.gameState === 'playing' && this.gameMode === 'survival') {
            if (this.lives <= 0) {
                this.triggerGameOver();
            }
        }

        const width = this.scale.width;
        const height = this.scale.height;

        this.starGraphics.clear();
        for(let i=0; i<this.stars.length; i++) {
            let s = this.stars[i];
            s.y += s.z * (this.isOverdrive ? 10 : 3); // Faster stars in overdrive
            if (s.y > height) {
                s.y = 0;
                s.x = Phaser.Math.Between(0, width);
            }
            this.starGraphics.fillStyle(0xffffff, s.z);
            this.starGraphics.fillRect(s.x, s.y, s.z * 2, s.z * 2);
        }

        if (this.player.body.velocity.length() > 50) {
            const targetAngle = this.player.body.velocity.angle();
            this.player.rotation = Phaser.Math.Angle.RotateTo(this.player.rotation, targetAngle, 0.2);
        }

        const maxHistoryLength = this.longTrail ? 40 : 15;
        this.trailHistory.push({ x: this.player.x, y: this.player.y });
        if (this.trailHistory.length > maxHistoryLength) {
            this.trailHistory.shift();
        }

        this.trailGraphics.clear();
        for (let i = 0; i < this.trailHistory.length; i++) {
            const point = this.trailHistory[i];
            const ratio = i / this.trailHistory.length; 
            
            const thickness = 2 + (ratio * 15);
            const alpha = Math.pow(ratio, 2); 

            this.trailGraphics.lineStyle(thickness, this.trailColor, alpha);
            
            if (i === 0) {
                this.trailGraphics.moveTo(point.x, point.y);
            } else {
                const prev = this.trailHistory[i - 1];
                this.trailGraphics.lineBetween(prev.x, prev.y, point.x, point.y);
            }
        }
    }

    startRhythmLoop() {
        this.currentBPM = 120; // Default BPM
        this.scheduleNextBeat();
    }

    scheduleNextBeat() {
        if (this.gameState !== 'playing') return;

        const beatMs = 60000 / this.currentBPM;
        
        // Ensure audio context is running
        if (window.sfx && window.sfx.ctx && window.sfx.ctx.state === 'suspended') {
            window.sfx.ctx.resume();
        }

        this.time.delayedCall(beatMs, () => {
            if (this.gameState !== 'playing') return;

            // --- AUDIO SYNTH ---
            let sequence;
            if (this.bgmMode === 'cyberpunk') {
                sequence = [110, 146.83, 110, 220, 110, 146.83];
            } else if (this.bgmMode === 'synthwave') {
                sequence = [440, 523.25, 659.25, 880];
            } else { // chiptune
                sequence = [261.63, 311.13, 392.00, 466.16];
            }
            
            try {
                if(window.sfx && window.sfx.ctx) {
                    const osc = window.sfx.ctx.createOscillator();
                    const gain = window.sfx.ctx.createGain();
                    
                    osc.type = this.bgmMode === 'cyberpunk' ? 'sawtooth' : 'square';
                    osc.frequency.value = sequence[this.beatIndex % sequence.length];
                    
                    gain.gain.setValueAtTime(0.05, window.sfx.ctx.currentTime);
                    gain.gain.exponentialRampToValueAtTime(0.001, window.sfx.ctx.currentTime + 0.1);
                    
                    if (this.bgmMode === 'synthwave' || this.bgmMode === 'cyberpunk') {
                        const filter = window.sfx.ctx.createBiquadFilter();
                        filter.type = 'lowpass';
                        filter.frequency.value = this.bgmMode === 'cyberpunk' ? 800 : 1200;
                        osc.connect(filter);
                        filter.connect(gain);
                    } else {
                        osc.connect(gain);
                    }
                    
                    gain.connect(window.sfx.ctx.destination);
                    osc.start();
                    osc.stop(window.sfx.ctx.currentTime + 0.1);
                }
            } catch (e) {}

            // --- VISUAL & SPAWN ---
            this.tweens.add({
                targets: this.cameras.main,
                zoom: 1.02,
                duration: 50,
                yoyo: true,
                ease: 'Quad.out'
            });
            
            if (this.beatIndex % 2 === 0 && this.targets.getLength() < 4) {
                this.spawnBeatTarget(beatMs * 2); 
            }

            this.beatIndex++;
            this.scheduleNextBeat(); // Recursive looping
        });
    }
}
