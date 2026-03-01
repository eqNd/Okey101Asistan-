// lib/engine/models/tile.dart
import 'package:hive/hive.dart';

part 'tile.g.dart';

enum TileColor { red, blue, yellow, black }

extension TileColorExtension on TileColor {
  String get turkishName {
    switch (this) {
      case TileColor.red: return 'Kırmızı';
      case TileColor.blue: return 'Mavi';
      case TileColor.yellow: return 'Sarı';
      case TileColor.black: return 'Siyah';
    }
  }
  String get shortName {
    switch (this) {
      case TileColor.red: return 'K';
      case TileColor.blue: return 'M';
      case TileColor.yellow: return 'S';
      case TileColor.black: return 'SY';
    }
  }
}

@HiveType(typeId: 0)
class Tile {
  @HiveField(0)
  final TileColor color;

  @HiveField(1)
  final int number; // 1-13, 0 = Okey/Joker

  @HiveField(2)
  final bool isFakeOkey; // Sahte Okey (kendi değeriyle oynar)

  bool isJoker; // Mevcut oyunda joker olarak işaretlendi mi?

  Tile({
    required this.color,
    required this.number,
    this.isFakeOkey = false,
    this.isJoker = false,
  });

  int get value => number; // Puan değeri
  bool get isOkey => number == 0 || isJoker;

  String get displayName => isJoker
      ? '★'
      : '$number${color.shortName}';

  @override
  bool operator ==(Object other) =>
      other is Tile && other.color == color && other.number == number;

  @override
  int get hashCode => Object.hash(color, number);

  @override
  String toString() => displayName;

  Tile copyWith({TileColor? color, int? number, bool? isJoker}) => Tile(
        color: color ?? this.color,
        number: number ?? this.number,
        isJoker: isJoker ?? this.isJoker,
      );
}
