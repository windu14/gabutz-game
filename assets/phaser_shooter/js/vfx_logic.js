Object.assign(MainScene.prototype, {
    createEpicExplosion(x, y) {
        const flashColor = this.epicVFX ? 0x00ffff : 0xffffff;
        const flash = this.add.rectangle(0, 0, this.scale.width, this.scale.height, flashColor);
        flash.setOrigin(0, 0);
        flash.setBlendMode(Phaser.BlendModes.ADD);
        this.tweens.add({
            targets: flash,
            alpha: 0,
            duration: this.epicVFX ? 300 : 150,
            ease: 'Cubic.out',
            onComplete: () => flash.destroy()
        });
        
        if (this.epicVFX) {
            this.cameras.main.shake(300, 0.04);
            const shockwave = this.add.circle(x, y, 10, 0x00ffff, 0);
            shockwave.setStrokeStyle(15, 0x00ffff, 1);
            shockwave.setBlendMode(Phaser.BlendModes.ADD);
            this.tweens.add({
                targets: shockwave,
                radius: 400,
                alpha: 0,
                duration: 400,
                ease: 'Sine.out',
                onComplete: () => shockwave.destroy()
            });
        }

        const sparks = this.add.particles(x, y, 'spark', {
            speed: { min: 400, max: 1200 },
            angle: { min: 0, max: 360 },
            scale: { start: 1, end: 0 },
            alpha: { start: 1, end: 0 },
            lifespan: { min: 200, max: 400 },
            blendMode: 'ADD',
            emitting: false,
            quantity: 30
        });
        sparks.explode();

        const debris = this.add.particles(x, y, 'debris', {
            speed: { min: 100, max: 600 },
            angle: { min: 0, max: 360 },
            scale: { start: 1.5, end: 0 },
            alpha: { start: 0.8, end: 0 },
            lifespan: { min: 500, max: 1200 },
            blendMode: 'ADD',
            emitting: false,
            quantity: 20
        });
        debris.explode();

        const ring = this.add.circle(x, y, 10, 0xffffff, 0);
        ring.setStrokeStyle(8, 0xffffff, 1);
        ring.setBlendMode(Phaser.BlendModes.ADD);
        this.tweens.add({
            targets: ring,
            radius: 200,
            alpha: 0,
            duration: 600,
            ease: 'Cubic.out',
            onComplete: () => ring.destroy()
        });
        
        this.time.delayedCall(1500, () => {
            sparks.destroy();
            debris.destroy();
        });
    },

    createFloatingText(x, y, msg, color, fontSize = '24px', bounce = false) {
        const colorStr = '#' + color.toString(16).padStart(6, '0');
        
        const floatText = this.add.text(x, y, msg, {
            fontFamily: '"Press Start 2P", monospace',
            fontSize: typeof fontSize === 'number' ? `${fontSize}px` : fontSize,
            color: colorStr,
            shadow: { offsetX: 0, offsetY: 0, color: colorStr, blur: 15, stroke: true, fill: true }
        }).setOrigin(0.5).setDepth(200);

        if (bounce) {
            this.tweens.add({
                targets: floatText,
                scale: 1.5,
                yoyo: true,
                duration: 200,
                ease: 'Back.out'
            });
        }

        this.tweens.add({
            targets: floatText,
            y: y - 80,
            alpha: 0,
            duration: 1000,
            ease: 'Cubic.out',
            onComplete: () => floatText.destroy()
        });
    },

    createDashRipple(x, y) {
        const ring = this.add.circle(x, y, 15, 0xffffff, 0);
        ring.setStrokeStyle(4, 0xffffff, 0.8);
        ring.setBlendMode(Phaser.BlendModes.ADD);
        this.tweens.add({
            targets: ring,
            radius: 80,
            alpha: 0,
            duration: 400,
            ease: 'Quad.out',
            onComplete: () => ring.destroy()
        });
    },

    createClickEffect(x, y) {
        const cross = this.add.graphics();
        cross.lineStyle(3, 0xffffff, 1);
        cross.beginPath();
        cross.moveTo(x - 20, y);
        cross.lineTo(x + 20, y);
        cross.moveTo(x, y - 20);
        cross.lineTo(x, y + 20);
        cross.strokePath();
        cross.setBlendMode(Phaser.BlendModes.ADD);

        this.tweens.add({
            targets: cross,
            scale: 0.2,
            alpha: 0,
            angle: 90,
            duration: 400,
            ease: 'Cubic.out',
            onComplete: () => cross.destroy()
        });
    }
});
