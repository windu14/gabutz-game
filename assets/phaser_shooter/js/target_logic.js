Object.assign(MainScene.prototype, {
    spawnBeatTarget(perfectDuration, forceGlitch = false) {
        const width = this.scale.width;
        const height = this.scale.height;
        const isMobile = width < 600;
        const paddingX = isMobile ? 50 : 100;
        
        const x = Phaser.Math.Between(paddingX, width - paddingX);
        const y = Phaser.Math.Between(paddingX, height - 100);
        
        let isGlitch = forceGlitch;
        
        // Glitch Logic
        if (!forceGlitch && this.glitchMode && !this.isOverdrive) {
            if (Math.random() < 0.3) { // 30% chance
                isGlitch = true;
                
                // Spawn 2 more glitch targets sequentially for chaos
                this.time.delayedCall(150, () => {
                    this.spawnBeatTarget(perfectDuration, true);
                });
                this.time.delayedCall(300, () => {
                    this.spawnBeatTarget(perfectDuration, true);
                });
            }
        }

        let color = isGlitch ? 0xff00ff : 0xffffff;
        
        // Core Target
        const targetObj = this.add.rectangle(x, y, 40, 40, color);
        targetObj.setOrigin(0.5);
        targetObj.setBlendMode(Phaser.BlendModes.ADD);
        this.physics.add.existing(targetObj);
        targetObj.body.setCircle(20, 0, 0);
        targetObj.isGlitch = isGlitch;
        
        if (isGlitch) {
            this.tweens.add({
                targets: targetObj,
                angle: 360,
                duration: 500,
                repeat: -1
            });
        }
        
        // Perfect time stamp
        targetObj.perfectTime = this.time.now + perfectDuration;
        
        // Timing Ring
        const ring = this.add.graphics();
        ring.lineStyle(4, color, 1);
        ring.strokeRect(-40, -40, 80, 80);
        ring.x = x;
        ring.y = y;
        ring.setBlendMode(Phaser.BlendModes.ADD);
        
        targetObj.timingRing = ring;
        
        this.targets.add(targetObj);
        
        // Animate Ring shrinking to Core
        this.tweens.add({
            targets: ring,
            scale: 0.5, 
            duration: perfectDuration,
            ease: 'Linear',
            onComplete: () => {
                // If it wasn't hit, it expires
                if (targetObj.active) {
                    this.missTarget(targetObj);
                }
            }
        });
    },

    missTarget(target) {
        this.combo = 1;
        if (this.gameMode === 'survival') {
            this.lives--;
        }
        this.sendHUDUpdate();
        if (window.soundError) window.soundError();
        this.createFloatingText(target.x, target.y - 30, 'MISS', 0xff0000);
        
        if (target.timingRing) target.timingRing.destroy();
        target.destroy();
    },

    hitTarget(player, target) {
        if (this.gameState !== 'playing') return;

        const diff = Math.abs(this.time.now - target.perfectTime);
        if (target.timingRing) target.timingRing.destroy();
        
        if (diff < 150) {
            // PERFECT
            this.combo++;
            this.score += 50 * this.combo;
            this.sendHUDUpdate();
            if (window.soundBonus) window.soundBonus();
            this.createEpicExplosion(target.x, target.y);
            if (this.comboVFX) {
                this.createFloatingText(target.x, target.y - 30, `COMBO x${this.combo}`, 0xffff00, 36, true);
            } else {
                this.createFloatingText(target.x, target.y - 30, 'PERFECT!', 0xffff00);
            }
            
            // Glitch trigger check
            if (target.isGlitch && !this.isOverdrive) {
                this.activateOverdrive();
            }

            // Chain lightning if overdrive
            if (this.isOverdrive) {
                this.triggerChainLightning(target.x, target.y);
            }
            
            this.physics.world.timeScale = 5.0; 
            this.time.delayedCall(80, () => {
                this.physics.world.timeScale = 1.0;
            });
        } else if (diff < 300) {
            // GOOD
            this.combo++;
            this.score += 10 * this.combo;
            
            if (this.gameMode === 'survival' && this.combo % 3 === 0) {
                this.lives++;
                this.createFloatingText(target.x, target.y - 60, '+1 LIFE!', 0xff0000, 24, true);
            }

            this.sendHUDUpdate();
            if (window.soundExplosion) window.soundExplosion();
            this.createEpicExplosion(target.x, target.y);
            this.createFloatingText(target.x, target.y - 30, 'GOOD', 0xffffff);
            
            if (this.isOverdrive) {
                this.triggerChainLightning(target.x, target.y);
            }
        } else {
            // EARLY
            this.combo = 1;
            this.score += 5;
            this.sendHUDUpdate();
            if (window.soundError) window.soundError();
            this.createEpicExplosion(target.x, target.y);
            this.createFloatingText(target.x, target.y - 30, 'EARLY', 0xaaaaaa);
        }
        
        target.destroy();
    },
    
    triggerChainLightning(startX, startY) {
        // Destroy up to 2 other targets automatically
        let destroyed = 0;
        this.targets.children.iterate((otherTarget) => {
            if (otherTarget && otherTarget.active && destroyed < 2) {
                const line = this.add.graphics();
                line.lineStyle(4, 0x00ffff, 1);
                line.beginPath();
                line.moveTo(startX, startY);
                line.lineTo(otherTarget.x, otherTarget.y);
                line.strokePath();
                line.setBlendMode(Phaser.BlendModes.ADD);
                
                this.tweens.add({
                    targets: line,
                    alpha: 0,
                    duration: 200,
                    onComplete: () => line.destroy()
                });
                
                this.score += 20 * this.combo;
                this.createEpicExplosion(otherTarget.x, otherTarget.y);
                if (otherTarget.timingRing) otherTarget.timingRing.destroy();
                otherTarget.destroy();
                destroyed++;
            }
        });
        if (destroyed > 0) this.sendHUDUpdate();
    },

    activateOverdrive() {
        this.isOverdrive = true;
        this.createFloatingText(this.scale.width / 2, this.scale.height / 2, 'OVERDRIVE!', 0xff00ff, 48, true);
        
        // Visual distortion effect
        const glitchFilter = this.add.rectangle(0, 0, this.scale.width, this.scale.height, 0xff00ff, 0.1);
        glitchFilter.setOrigin(0,0);
        glitchFilter.setBlendMode(Phaser.BlendModes.DIFFERENCE);
        glitchFilter.setDepth(999);
        
        this.tweens.add({
            targets: glitchFilter,
            alpha: 0.3,
            yoyo: true,
            repeat: -1,
            duration: 100
        });
        
        this.currentBPM = 180;
        
        this.time.delayedCall(10000, () => {
            this.isOverdrive = false;
            this.currentBPM = 120;
            glitchFilter.destroy();
        });
    }
});
