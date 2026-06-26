// Simple Web Audio API Synthesizer untuk efek retro 16-bit
class SoundFX {
    constructor() {
        this.ctx = null;
    }
    
    init() {
        if (!this.ctx) {
            const AudioContext = window.AudioContext || window.webkitAudioContext;
            if (AudioContext) {
                this.ctx = new AudioContext();
            }
        }
        if (this.ctx && this.ctx.state === 'suspended') {
            this.ctx.resume();
        }
    }

    playTone(startFreq, endFreq, type, duration, vol) {
        if (!this.ctx) return;
        try {
            const osc = this.ctx.createOscillator();
            const gain = this.ctx.createGain();
            osc.type = type;
            osc.frequency.setValueAtTime(startFreq, this.ctx.currentTime);
            if (endFreq) {
                osc.frequency.exponentialRampToValueAtTime(endFreq, this.ctx.currentTime + duration);
            }
            gain.gain.setValueAtTime(vol, this.ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + duration);
            osc.connect(gain);
            gain.connect(this.ctx.destination);
            osc.start();
            osc.stop(this.ctx.currentTime + duration);
        } catch (e) {
            console.warn('Audio playTone error', e);
        }
    }

    playNoise(duration, vol) {
        if (!this.ctx) return;
        try {
            const bufferSize = this.ctx.sampleRate * duration;
            const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
            const data = buffer.getChannelData(0);
            for (let i = 0; i < bufferSize; i++) {
                data[i] = Math.random() * 2 - 1;
            }
            const noiseSource = this.ctx.createBufferSource();
            noiseSource.buffer = buffer;
            
            const filter = this.ctx.createBiquadFilter();
            filter.type = 'lowpass';
            filter.frequency.setValueAtTime(1000, this.ctx.currentTime);
            filter.frequency.exponentialRampToValueAtTime(100, this.ctx.currentTime + duration);

            const gain = this.ctx.createGain();
            gain.gain.setValueAtTime(vol, this.ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + duration);
            
            noiseSource.connect(filter);
            filter.connect(gain);
            gain.connect(this.ctx.destination);
            noiseSource.start();
        } catch (e) {
            console.warn('Audio playNoise error', e);
        }
    }
}

window.sfx = new SoundFX();

// Efek Suara Retro
window.soundBlip = () => window.sfx.playTone(800, null, 'square', 0.1, 0.1);
window.soundGo = () => window.sfx.playTone(1200, 800, 'square', 0.3, 0.1);
window.soundDash = () => window.sfx.playTone(300, 100, 'sawtooth', 0.15, 0.05);
window.soundExplosion = () => window.sfx.playNoise(0.5, 0.5); 
window.soundError = () => window.sfx.playTone(150, 50, 'sawtooth', 0.3, 0.2);
window.soundBonus = () => window.sfx.playTone(1000, 2000, 'square', 0.2, 0.1);
