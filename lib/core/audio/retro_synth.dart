// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'dart:js' as js;

class RetroSynth {
  static final RetroSynth _instance = RetroSynth._internal();
  factory RetroSynth() => _instance;
  RetroSynth._internal() {
    _init();
  }

  bool _initialized = false;

  void _init() {
    if (!kIsWeb || _initialized) return;
    try {
      final script = html.ScriptElement()
        ..type = 'text/javascript'
        ..innerHtml = '''
          window.retroSynthContext = window.retroSynthContext || (window.AudioContext || window.webkitAudioContext) ? new (window.AudioContext || window.webkitAudioContext)() : null;
          window.retroSynthLoop = null;
          window.retroSynthPlay = function() {
            if (!window.retroSynthContext) return;
            if (window.retroSynthContext.state === "suspended") window.retroSynthContext.resume();
            if (window.retroSynthLoop) return;
            
            const sequence = [440, 523.25, 659.25, 880, 659.25, 523.25, 440, 329.63, 440, 523.25, 659.25, 880];
            let idx = 0;
            window.retroSynthLoop = setInterval(() => {
              const osc = window.retroSynthContext.createOscillator();
              const gain = window.retroSynthContext.createGain();
              osc.type = 'sawtooth';
              osc.frequency.value = sequence[idx];
              gain.gain.setValueAtTime(0.3, window.retroSynthContext.currentTime);
              gain.gain.exponentialRampToValueAtTime(0.001, window.retroSynthContext.currentTime + 0.1);
              
              // Add a slight filter for synthwave feel
              const filter = window.retroSynthContext.createBiquadFilter();
              filter.type = 'lowpass';
              filter.frequency.value = 1200;
              
              osc.connect(filter);
              filter.connect(gain);
              gain.connect(window.retroSynthContext.destination);
              
              osc.start();
              osc.stop(window.retroSynthContext.currentTime + 0.1);
              idx = (idx + 1) % sequence.length;
            }, 120);
          };
          window.retroSynthStop = function() {
            if (window.retroSynthLoop) {
              clearInterval(window.retroSynthLoop);
              window.retroSynthLoop = null;
            }
          };
          window.retroSynthPlayPreview = function(mode) {
            if (!window.retroSynthContext) return;
            if (window.retroSynthContext.state === "suspended") window.retroSynthContext.resume();
            
            let sequence;
            if (mode === 'cyberpunk') {
                sequence = [110, 146.83, 110, 220, 110, 146.83];
            } else if (mode === 'synthwave') {
                sequence = [440, 523.25, 659.25, 880];
            } else { 
                sequence = [261.63, 311.13, 392.00, 466.16];
            }
            
            let idx = 0;
            let loopCount = 0;
            
            const previewTimer = setInterval(() => {
              if (loopCount > 10) {
                 clearInterval(previewTimer);
                 return;
              }
              const osc = window.retroSynthContext.createOscillator();
              const gain = window.retroSynthContext.createGain();
              osc.type = mode === 'cyberpunk' ? 'sawtooth' : 'square';
              osc.frequency.value = sequence[idx];
              gain.gain.setValueAtTime(0.3, window.retroSynthContext.currentTime);
              gain.gain.exponentialRampToValueAtTime(0.001, window.retroSynthContext.currentTime + 0.1);
              
              if (mode === 'synthwave' || mode === 'cyberpunk') {
                  const filter = window.retroSynthContext.createBiquadFilter();
                  filter.type = 'lowpass';
                  filter.frequency.value = mode === 'cyberpunk' ? 800 : 1200;
                  osc.connect(filter);
                  filter.connect(gain);
              } else {
                  osc.connect(gain);
              }
              
              gain.connect(window.retroSynthContext.destination);
              osc.start();
              osc.stop(window.retroSynthContext.currentTime + 0.1);
              
              idx = (idx + 1) % sequence.length;
              loopCount++;
            }, 120);
          };
        ''';
      html.document.head!.append(script);
      _initialized = true;
    } catch (e) {
      debugPrint('Error init synth: $e');
    }
  }

  void playBGM() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('retroSynthPlay');
    } catch (e) {
      // Ignore
    }
  }

  void stopBGM() {
    if (!kIsWeb) return;
    try {
      js.context.callMethod('retroSynthStop');
    } catch (e) {
      // Ignore
    }
  }

  void playPreview(String mode) {
    if (!kIsWeb) return;
    try {
      stopBGM();
      js.context.callMethod('retroSynthPlayPreview', [mode]);
      Future.delayed(const Duration(seconds: 2), () {
        playBGM();
      });
    } catch (e) {
      // Ignore
    }
  }
}

