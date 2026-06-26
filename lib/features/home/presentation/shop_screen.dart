import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_2/core/widgets/indie_button.dart';
import 'package:flutter_application_2/core/widgets/retro_marquee.dart';
import 'package:flutter_application_2/features/home/providers/equipment_provider.dart';
import 'package:flutter_application_2/features/home/providers/score_provider.dart';
import 'package:flutter_application_2/core/audio/retro_synth.dart';

// --- MODELS ---
enum ShopCategory { trails, vfx, powerups, sound }

class ShopItemDef {
  final String id;
  final String name;
  final int price;
  final IconData icon;
  final ShopCategory category;
  final String description;
  final dynamic actionPayload;

  ShopItemDef({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
    required this.category,
    required this.description,
    this.actionPayload,
  });
}

final shopItems = [
  // TRAILS
  ShopItemDef(id: 'trail_pink', name: 'NEON PINK TRAIL', price: 1000, icon: Icons.color_lens, category: ShopCategory.trails, description: 'MEMBAKAR ANGKASA DENGAN JEJAK PLASMA MAGENTA MENYALA!', actionPayload: 0xff00ff),
  ShopItemDef(id: 'trail_green', name: 'NEON GREEN TRAIL', price: 1000, icon: Icons.brush, category: ShopCategory.trails, description: 'JEJAK HIJAU STABILO UNTUK ESTETIKA MATRIX SEJATI!', actionPayload: 0x00ff00),
  ShopItemDef(id: 'trail_blue', name: 'COBALT BLUE TRAIL', price: 1000, icon: Icons.water_drop, category: ShopCategory.trails, description: 'MENDINGINKAN MESIN DENGAN BIRU KOBALT SUPER DINGIN!', actionPayload: 0x00aaff),
  ShopItemDef(id: 'trail_purple', name: 'DEEP PURPLE TRAIL', price: 1000, icon: Icons.nightlight_round, category: ShopCategory.trails, description: 'JEJAK UNGU GELAP DARI MATERI GELAP ALAM SEMESTA!', actionPayload: 0x8a2be2),
  ShopItemDef(id: 'trail_long', name: 'LONG TAIL EXTENSION', price: 1500, icon: Icons.linear_scale, category: ShopCategory.trails, description: 'MEMANJANGKAN DURASI EKOR ROKET HINGGA 3 KALI LIPAT! DAPAT DIGUNAKAN BERSAMA WARNA APA PUN.'),
  
  // VFX
  ShopItemDef(id: 'vfx_epic', name: 'EPIC EXPLOSION', price: 1000, icon: Icons.local_fire_department, category: ShopCategory.vfx, description: 'LEDAKAN SUPER MASIF! MENGGUNCANG LAYAR DAN MERUSAK MATA (SECARA BAIK)!'),
  ShopItemDef(id: 'vfx_combo', name: 'GRAPHIC COMBO', price: 1000, icon: Icons.flash_on, category: ShopCategory.vfx, description: 'ANGKA COMBO RAKSASA MEMANTUL SETIAP KALI PERFECT HIT!'),
  
  // POWERUPS
  ShopItemDef(id: 'power_speed', name: '2X SPEED THRUSTER', price: 2000, icon: Icons.speed, category: ShopCategory.powerups, description: 'GANDAKAN DAYA LONTAR ROKET! MENGUBAH GAME MENJADI MODE NERAKA!'),
  ShopItemDef(id: 'power_glitch', name: 'GLITCH INJECTOR', price: 5000, icon: Icons.bug_report, category: ShopCategory.powerups, description: 'DISTORSI REALITA! PERFECT HIT = 1.5X BPM & CHAIN LIGHTNING!'),

  // SOUND
  ShopItemDef(id: 'bgm_cyberpunk', name: 'CYBERPUNK (FAST)', price: 1000, icon: Icons.music_note, category: ShopCategory.sound, description: 'IRAMA SUPER CEPAT, BASS MENENDANG, DAN TEMPO AGRESIF!', actionPayload: 'cyberpunk'),
  ShopItemDef(id: 'bgm_synthwave', name: 'SYNTHWAVE (CHILL)', price: 1000, icon: Icons.waves, category: ShopCategory.sound, description: 'NADA ARPEGGIO CHILL UNTUK PERJALANAN ANTAR GALAKSI YANG SANTAI!', actionPayload: 'synthwave'),
  ShopItemDef(id: 'bgm_chiptune', name: 'CHIPTUNE (RETRO)', price: 1000, icon: Icons.videogame_asset, category: ShopCategory.sound, description: 'BUNYI KLASIK 16-BIT RETRO SEPERTI MESIN ARCADE LAMA!', actionPayload: 'chiptune'),
];

// --- SCREEN ---
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final coins = ref.watch(coinsProvider);

    return Column(
      children: [
        // --- HEADER ---
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Text(
            'TOKO GABUTZ',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              color: Colors.white, 
              // shadows: const [Shadow(color: Colors.white54, offset: Offset(4, 4))]
            ),
          ),
        ),

        // --- COINS BALANCE ---
        Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2),
            // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))]
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.monetization_on, color: Colors.white, size: 24.w),
              SizedBox(width: 16.w),
              Text(
                '$coins C',
                style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16.sp),
              )
            ],
          ),
        ),
        
        SizedBox(height: 16.h),

        // --- CONTENT ---
        Expanded(
          child: _selectedCategory == null ? _buildCategoryCarousel() : _buildItemList(),
        ),
      ],
    );
  }

  Widget _buildCategoryCarousel() {
    final categories = [
      {'title': 'TRAILS', 'icon': Icons.stream, 'cat': ShopCategory.trails},
      {'title': 'VFX', 'icon': Icons.auto_awesome, 'cat': ShopCategory.vfx},
      {'title': 'POWER-UPS', 'icon': Icons.bolt, 'cat': ShopCategory.powerups},
      {'title': 'SOUND', 'icon': Icons.speaker, 'cat': ShopCategory.sound},
    ];

    return ListWheelScrollView.useDelegate(
      itemExtent: 150.h,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 1.5,
      perspective: 0.003,
      onSelectedItemChanged: (idx) {},
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat['cat'] as ShopCategory;
              });
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 32.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 4),
                // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(6, 6))]
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(cat['icon'] as IconData, size: 40.w, color: Colors.black),
                    SizedBox(height: 12.h),
                    Text(
                      cat['title'] as String,
                      style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 18.sp),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: categories.length,
      ),
    );
  }

  Widget _buildItemList() {
    final items = shopItems.where((i) => i.category == _selectedCategory).toList();
    final purchasedItems = ref.watch(purchasedItemsProvider);
    final coins = ref.watch(coinsProvider);

    return Column(
      children: [
        // Back Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: IndieButton(
            label: '< BACK TO CATEGORIES',
            icon: Icons.arrow_back,
            isPrimary: false,
            onTap: () {
              setState(() {
                _selectedCategory = null;
              });
            },
          ),
        ),
        SizedBox(height: 8.h),
        // List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isOwned = purchasedItems.contains(item.id);
              final isEquipped = _isItemEquipped(item);

              String label;
              if (!isOwned) {
                label = '${item.name}\n[BUY ${item.price} C]';
              } else {
                label = isEquipped ? '${item.name}\n[EQUIPPED]' : '${item.name}\n[EQUIP]';
              }

              return Container(
                margin: EdgeInsets.only(bottom: 24.h),
                decoration: BoxDecoration(
                  color: isEquipped ? Colors.white : Colors.black,
                  border: Border.all(color: Colors.white, width: 4),
                  // boxShadow: const [BoxShadow(color: Colors.white24, offset: Offset(4, 4))],
                ),
                child: InkWell(
                  onTap: () => _handleItemTap(item, isOwned, isEquipped, coins),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                        child: Row(
                          children: [
                            Icon(item.icon, size: 36.w, color: isEquipped ? Colors.black : Colors.white),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                label,
                                style: GoogleFonts.pressStart2p(
                                  color: isEquipped ? Colors.black : Colors.white, 
                                  fontSize: 12.sp,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Marquee integrated seamlessly without inner borders
                      Container(
                        color: Colors.black, // Always black background for marquee to stand out
                        child: RetroMarquee(text: item.description),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _isItemEquipped(ShopItemDef item) {
    if (item.id == 'trail_long') {
      return ref.watch(longTrailProvider);
    } else if (item.category == ShopCategory.trails) {
      return ref.watch(trailColorProvider) == item.actionPayload;
    } else if (item.id == 'vfx_epic') {
      return ref.watch(epicExplosionProvider);
    } else if (item.id == 'vfx_combo') {
      return ref.watch(graphicComboProvider);
    } else if (item.id == 'power_speed') {
      return ref.watch(speedBoostProvider);
    } else if (item.id == 'power_glitch') {
      return ref.watch(glitchModeProvider);
    } else if (item.category == ShopCategory.sound) {
      return ref.watch(bgmProvider) == item.actionPayload;
    }
    return false;
  }

  void _handleItemTap(ShopItemDef item, bool isOwned, bool isEquipped, int coins) {
    if (item.category == ShopCategory.sound) {
      RetroSynth().playPreview(item.actionPayload as String);
    }
    
    if (!isOwned) {
      if (coins >= item.price) {
        ref.read(coinsProvider.notifier).addCoins(-item.price);
        ref.read(purchasedItemsProvider.notifier).unlock(item.id);
        _equipItem(item, true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PURCHASE SUCCESSFUL!', style: GoogleFonts.pressStart2p(fontSize: 12.sp)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('NOT ENOUGH COINS!', style: GoogleFonts.pressStart2p(fontSize: 12.sp)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          )
        );
      }
    } else {
      _equipItem(item, !isEquipped);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(!isEquipped ? 'EQUIPPED' : 'UNEQUIPPED', style: GoogleFonts.pressStart2p(fontSize: 12.sp, color: Colors.black)),
          backgroundColor: !isEquipped ? Colors.cyanAccent : Colors.grey,
          duration: const Duration(seconds: 1),
        )
      );
    }
  }

  void _equipItem(ShopItemDef item, bool state) {
    if (item.id == 'trail_long') {
      ref.read(longTrailProvider.notifier).set(state);
    } else if (item.category == ShopCategory.trails) {
      ref.read(trailColorProvider.notifier).setColor(state ? item.actionPayload as int : 0xffffff);
    } else if (item.id == 'vfx_epic') {
      ref.read(epicExplosionProvider.notifier).set(state);
    } else if (item.id == 'vfx_combo') {
      ref.read(graphicComboProvider.notifier).set(state);
    } else if (item.id == 'power_speed') {
      ref.read(speedBoostProvider.notifier).set(state);
    } else if (item.id == 'power_glitch') {
      ref.read(glitchModeProvider.notifier).set(state);
    } else if (item.category == ShopCategory.sound) {
      if (state) {
        ref.read(bgmProvider.notifier).set(item.actionPayload as String);
      }
    }
  }
}
