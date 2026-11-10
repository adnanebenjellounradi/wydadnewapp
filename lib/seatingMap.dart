import 'package:flutter/material.dart';
import 'dart:convert';

// ==================== MODÈLE DE DONNÉES ====================

class Seat {
  final int id;
  final double x;
  final double y;
  final String label;
  final String status; // 'available', 'reserved', 'unavailable'
  final double price;
  final String category;
  bool isSelected;

  Seat({
    required this.id,
    required this.x,
    required this.y,
    required this.label,
    required this.status,
    required this.price,
    required this.category,
    this.isSelected = false,
  });

  factory Seat.fromJson(Map<String, dynamic> json) {
    return Seat(
      id: json['id'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      label: json['label'],
      status: json['status'],
      price: json['price'].toDouble(),
      category: json['category'],
    );
  }
}

// ==================== DONNÉES RÉELLES DES SIÈGES ====================

Map<String, dynamic> getSeatingData() {
  return {
    "name": "new",
    "width": 2500,
    "height": 900,
    "seats": [
      {"id": 1, "x": 434.66666666666634, "y": 78.79165818956163, "label": "S1", "status": "available", "price": 0, "category": "standard"},
      {"id": 2, "x": 474.6666666666663, "y": 78.79165818956163, "label": "S2", "status": "available", "price": 0, "category": "standard"},
      {"id": 3, "x": 514.6666666666663, "y": 78.79165818956163, "label": "S3", "status": "available", "price": 0, "category": "standard"},
      {"id": 4, "x": 554.6666666666663, "y": 78.79165818956163, "label": "S4", "status": "available", "price": 0, "category": "standard"},
      {"id": 5, "x": 594.6666666666663, "y": 78.79165818956163, "label": "S5", "status": "available", "price": 0, "category": "standard"},
      {"id": 6, "x": 634.6666666666663, "y": 78.79165818956163, "label": "S6", "status": "available", "price": 0, "category": "standard"},
      {"id": 7, "x": 674.6666666666663, "y": 78.79165818956163, "label": "S7", "status": "available", "price": 0, "category": "standard"},
      {"id": 8, "x": 452.66666666666634, "y": 128.52499389648438, "label": "S8", "status": "available", "price": 0, "category": "standard"},
      {"id": 9, "x": 492.6666666666663, "y": 128.52499389648438, "label": "S9", "status": "available", "price": 0, "category": "standard"},
      {"id": 10, "x": 532.6666666666663, "y": 128.52499389648438, "label": "S10", "status": "available", "price": 0, "category": "standard"},
      {"id": 11, "x": 572.6666666666663, "y": 128.52499389648438, "label": "S11", "status": "available", "price": 0, "category": "standard"},
      {"id": 12, "x": 612.6666666666663, "y": 128.52499389648438, "label": "S12", "status": "available", "price": 0, "category": "standard"},
      {"id": 13, "x": 652.6666666666663, "y": 128.52499389648438, "label": "S13", "status": "available", "price": 0, "category": "standard"},
      {"id": 14, "x": 692.6666666666663, "y": 128.52499389648438, "label": "S14", "status": "available", "price": 0, "category": "standard"},
      {"id": 15, "x": 467.0186666666665, "y": 173.63610500759546, "label": "S15", "status": "available", "price": 0, "category": "standard"},
      {"id": 16, "x": 507.0186666666668, "y": 173.63610500759546, "label": "S16", "status": "available", "price": 0, "category": "standard"},
      {"id": 17, "x": 547.0186666666668, "y": 173.63610500759546, "label": "S17", "status": "available", "price": 0, "category": "standard"},
      {"id": 18, "x": 587.0186666666668, "y": 173.63610500759546, "label": "S18", "status": "available", "price": 0, "category": "standard"},
      {"id": 19, "x": 627.0186666666668, "y": 173.63610500759546, "label": "S19", "status": "available", "price": 0, "category": "standard"},
      {"id": 20, "x": 667.0186666666668, "y": 173.63610500759546, "label": "S20", "status": "available", "price": 0, "category": "standard"},
      {"id": 21, "x": 707.0186666666668, "y": 173.63610500759546, "label": "S21", "status": "available", "price": 0, "category": "standard"},
      {"id": 22, "x": 479.66666666666686, "y": 226.6361050075955, "label": "S22", "status": "available", "price": 0, "category": "standard"},
      {"id": 23, "x": 519.6666666666669, "y": 226.6361050075955, "label": "S23", "status": "available", "price": 0, "category": "standard"},
      {"id": 24, "x": 559.6666666666669, "y": 226.6361050075955, "label": "S24", "status": "available", "price": 0, "category": "standard"},
      {"id": 25, "x": 599.6666666666669, "y": 226.6361050075955, "label": "S25", "status": "available", "price": 0, "category": "standard"},
      {"id": 26, "x": 639.6666666666669, "y": 226.6361050075955, "label": "S26", "status": "available", "price": 0, "category": "standard"},
      {"id": 27, "x": 679.6666666666669, "y": 226.6361050075955, "label": "S27", "status": "available", "price": 0, "category": "standard"},
      {"id": 28, "x": 719.6666666666669, "y": 226.6361050075955, "label": "S28", "status": "available", "price": 0, "category": "standard"},
      {"id": 30, "x": 79, "y": 82.45833333333333, "label": "S30", "status": "available", "price": 0, "category": "standard"},
      {"id": 31, "x": 119, "y": 82.45833333333333, "label": "S30", "status": "available", "price": 0, "category": "standard"},
      {"id": 32, "x": 159, "y": 82.45833333333333, "label": "S31", "status": "available", "price": 0, "category": "standard"},
      {"id": 33, "x": 92, "y": 130.45833333333331, "label": "S32", "status": "available", "price": 0, "category": "standard"},
      {"id": 34, "x": 132, "y": 130.45833333333331, "label": "S33", "status": "available", "price": 0, "category": "standard"},
      {"id": 35, "x": 172, "y": 130.45833333333331, "label": "S34", "status": "available", "price": 0, "category": "standard"},
      {"id": 36, "x": 105, "y": 177.45833333333331, "label": "S35", "status": "available", "price": 0, "category": "standard"},
      {"id": 37, "x": 145, "y": 177.45833333333331, "label": "S36", "status": "available", "price": 0, "category": "standard"},
      {"id": 38, "x": 185, "y": 177.45833333333331, "label": "S37", "status": "available", "price": 0, "category": "standard"},
      {"id": 39, "x": 199, "y": 82.45833333333333, "label": "S38", "status": "available", "price": 0, "category": "standard"},
      {"id": 40, "x": 212, "y": 130.45833333333331, "label": "S39", "status": "available", "price": 0, "category": "standard"},
      {"id": 41, "x": 225, "y": 177.45833333333331, "label": "S40", "status": "available", "price": 0, "category": "standard"},
      {"id": 42, "x": 117, "y": 223.45833333333331, "label": "S41", "status": "available", "price": 0, "category": "standard"},
      {"id": 43, "x": 157, "y": 223.45833333333331, "label": "S42", "status": "available", "price": 0, "category": "standard"},
      {"id": 44, "x": 197, "y": 223.45833333333331, "label": "S43", "status": "available", "price": 0, "category": "standard"},
      {"id": 45, "x": 137, "y": 273.4583333333333, "label": "S44", "status": "available", "price": 0, "category": "standard"},
      {"id": 46, "x": 177, "y": 273.4583333333333, "label": "S45", "status": "available", "price": 0, "category": "standard"},
      {"id": 47, "x": 217, "y": 273.4583333333333, "label": "S46", "status": "available", "price": 0, "category": "standard"},
      {"id": 48, "x": 153, "y": 319.45833333333326, "label": "S47", "status": "available", "price": 0, "category": "standard"},
      {"id": 49, "x": 193, "y": 319.45833333333326, "label": "S48", "status": "available", "price": 0, "category": "standard"},
      {"id": 50, "x": 233, "y": 319.45833333333326, "label": "S49", "status": "available", "price": 0, "category": "standard"},
      {"id": 51, "x": 237, "y": 223.45833333333331, "label": "S50", "status": "available", "price": 0, "category": "standard"},
      {"id": 52, "x": 257, "y": 273.4583333333333, "label": "S51", "status": "available", "price": 0, "category": "standard"},
      {"id": 53, "x": 273, "y": 319.45833333333326, "label": "S52", "status": "available", "price": 0, "category": "standard"},
      {"id": 54, "x": 496, "y": 366.6173037015477, "label": "S53", "status": "available", "price": 0, "category": "standard"},
      {"id": 55, "x": 536, "y": 366.6173037015477, "label": "S54", "status": "available", "price": 0, "category": "standard"},
      {"id": 56, "x": 576, "y": 366.6173037015477, "label": "S55", "status": "available", "price": 0, "category": "standard"},
      {"id": 57, "x": 616, "y": 366.6173037015477, "label": "S56", "status": "available", "price": 0, "category": "standard"},
      {"id": 58, "x": 656, "y": 366.6173037015477, "label": "S57", "status": "available", "price": 0, "category": "standard"},
      {"id": 59, "x": 696, "y": 366.6173037015477, "label": "S58", "status": "available", "price": 0, "category": "standard"},
      {"id": 60, "x": 736, "y": 366.6173037015477, "label": "S59", "status": "available", "price": 0, "category": "standard"},
      {"id": 61, "x": 511, "y": 415.5250009390022, "label": "S60", "status": "available", "price": 0, "category": "standard"},
      {"id": 62, "x": 551, "y": 415.5250009390022, "label": "S61", "status": "available", "price": 0, "category": "standard"},
      {"id": 63, "x": 591, "y": 415.5250009390022, "label": "S62", "status": "available", "price": 0, "category": "standard"},
      {"id": 64, "x": 631, "y": 415.5250009390022, "label": "S63", "status": "available", "price": 0, "category": "standard"},
      {"id": 65, "x": 671, "y": 415.5250009390022, "label": "S64", "status": "available", "price": 0, "category": "standard"},
      {"id": 66, "x": 711, "y": 415.5250009390022, "label": "S65", "status": "available", "price": 0, "category": "standard"},
      {"id": 67, "x": 751, "y": 415.5250009390022, "label": "S66", "status": "available", "price": 0, "category": "standard"},
      {"id": 68, "x": 522, "y": 463.6788470928484, "label": "S67", "status": "available", "price": 0, "category": "standard"},
      {"id": 69, "x": 562, "y": 463.6788470928484, "label": "S68", "status": "available", "price": 0, "category": "standard"},
      {"id": 70, "x": 602, "y": 463.6788470928484, "label": "S69", "status": "available", "price": 0, "category": "standard"},
      {"id": 71, "x": 642, "y": 463.6788470928484, "label": "S70", "status": "available", "price": 0, "category": "standard"},
      {"id": 72, "x": 682, "y": 463.6788470928484, "label": "S71", "status": "available", "price": 0, "category": "standard"},
      {"id": 73, "x": 722, "y": 463.6788470928484, "label": "S72", "status": "available", "price": 0, "category": "standard"},
      {"id": 74, "x": 762, "y": 463.6788470928484, "label": "S73", "status": "available", "price": 0, "category": "standard"},
      {"id": 75, "x": 538, "y": 511.5250009390021, "label": "S74", "status": "available", "price": 0, "category": "standard"},
      {"id": 76, "x": 578, "y": 511.5250009390021, "label": "S75", "status": "available", "price": 0, "category": "standard"},
      {"id": 77, "x": 618, "y": 511.5250009390021, "label": "S76", "status": "available", "price": 0, "category": "standard"},
      {"id": 78, "x": 658, "y": 511.5250009390021, "label": "S77", "status": "available", "price": 0, "category": "standard"},
      {"id": 79, "x": 698, "y": 511.5250009390021, "label": "S78", "status": "available", "price": 0, "category": "standard"},
      {"id": 80, "x": 738, "y": 511.5250009390021, "label": "S79", "status": "available", "price": 0, "category": "standard"},
      {"id": 81, "x": 778, "y": 511.5250009390021, "label": "S80", "status": "available", "price": 0, "category": "standard"},
      {"id": 82, "x": 776, "y": 366.6173037015477, "label": "S81", "status": "available", "price": 0, "category": "standard"},
      {"id": 83, "x": 816, "y": 366.6173037015477, "label": "S82", "status": "available", "price": 0, "category": "standard"},
      {"id": 84, "x": 856, "y": 366.6173037015477, "label": "S83", "status": "available", "price": 0, "category": "standard"},
      {"id": 85, "x": 896, "y": 366.6173037015477, "label": "S84", "status": "available", "price": 0, "category": "standard"},
      {"id": 86, "x": 936, "y": 366.6173037015477, "label": "S85", "status": "available", "price": 0, "category": "standard"},
      {"id": 87, "x": 791, "y": 415.5250009390022, "label": "S86", "status": "available", "price": 0, "category": "standard"},
      {"id": 88, "x": 831, "y": 415.5250009390022, "label": "S87", "status": "available", "price": 0, "category": "standard"},
      {"id": 89, "x": 871, "y": 415.5250009390022, "label": "S88", "status": "available", "price": 0, "category": "standard"},
      {"id": 90, "x": 911, "y": 415.5250009390022, "label": "S89", "status": "available", "price": 0, "category": "standard"},
      {"id": 91, "x": 802, "y": 463.6788470928484, "label": "S90", "status": "available", "price": 0, "category": "standard"},
      {"id": 92, "x": 842, "y": 463.6788470928484, "label": "S91", "status": "available", "price": 0, "category": "standard"},
      {"id": 93, "x": 882, "y": 463.6788470928484, "label": "S92", "status": "available", "price": 0, "category": "standard"},
      {"id": 94, "x": 922, "y": 463.6788470928484, "label": "S93", "status": "available", "price": 0, "category": "standard"},
      {"id": 95, "x": 818, "y": 511.5250009390021, "label": "S94", "status": "available", "price": 0, "category": "standard"},
      {"id": 96, "x": 858, "y": 511.5250009390021, "label": "S95", "status": "available", "price": 0, "category": "standard"},
      {"id": 97, "x": 898, "y": 511.5250009390021, "label": "S96", "status": "available", "price": 0, "category": "standard"},
      {"id": 98, "x": 938, "y": 511.5250009390021, "label": "S97", "status": "available", "price": 0, "category": "standard"},
      {"id": 100, "x": 976, "y": 366.6173037015477, "label": "S98", "status": "available", "price": 0, "category": "standard"},
      {"id": 101, "x": 951, "y": 415.5250009390022, "label": "S99", "status": "available", "price": 0, "category": "standard"},
      {"id": 102, "x": 991, "y": 415.5250009390022, "label": "S100", "status": "available", "price": 0, "category": "standard"},
      {"id": 103, "x": 962, "y": 463.6788470928484, "label": "S101", "status": "available", "price": 0, "category": "standard"},
      {"id": 104, "x": 1002, "y": 463.6788470928484, "label": "S102", "status": "available", "price": 0, "category": "standard"},
      {"id": 105, "x": 978, "y": 511.5250009390021, "label": "S103", "status": "available", "price": 0, "category": "standard"},
      {"id": 106, "x": 1018, "y": 511.5250009390021, "label": "S104", "status": "available", "price": 0, "category": "standard"},
      {"id": 107, "x": 165, "y": 368.45833333333326, "label": "S105", "status": "available", "price": 0, "category": "standard"},
      {"id": 108, "x": 205, "y": 368.45833333333326, "label": "S106", "status": "available", "price": 0, "category": "standard"},
      {"id": 109, "x": 245, "y": 368.45833333333326, "label": "S107", "status": "available", "price": 0, "category": "standard"},
      {"id": 110, "x": 285, "y": 368.45833333333326, "label": "S108", "status": "available", "price": 0, "category": "standard"},
      {"id": 111, "x": 177, "y": 417.45833333333326, "label": "S109", "status": "available", "price": 0, "category": "standard"},
      {"id": 112, "x": 217, "y": 417.45833333333326, "label": "S110", "status": "available", "price": 0, "category": "standard"},
      {"id": 113, "x": 257, "y": 417.45833333333326, "label": "S111", "status": "available", "price": 0, "category": "standard"},
      {"id": 114, "x": 297, "y": 417.45833333333326, "label": "S112", "status": "available", "price": 0, "category": "standard"},
      {"id": 115, "x": 187, "y": 462.5250015258789, "label": "S113", "status": "available", "price": 0, "category": "standard"},
      {"id": 116, "x": 227, "y": 462.5250015258789, "label": "S114", "status": "available", "price": 0, "category": "standard"},
      {"id": 117, "x": 267, "y": 462.5250015258789, "label": "S115", "status": "available", "price": 0, "category": "standard"},
      {"id": 119, "x": 307, "y": 462.5250015258789, "label": "S116", "status": "available", "price": 0, "category": "standard"},
      {"id": 120, "x": 200, "y": 511.5250015258789, "label": "S117", "status": "available", "price": 0, "category": "standard"},
      {"id": 121, "x": 240, "y": 511.5250015258789, "label": "S118", "status": "available", "price": 0, "category": "standard"},
      {"id": 122, "x": 280, "y": 511.5250015258789, "label": "S119", "status": "available", "price": 0, "category": "standard"},
      {"id": 123, "x": 320, "y": 511.5250015258789, "label": "S120", "status": "available", "price": 0, "category": "standard"},
      {"id": 128, "x": 208, "y": 559.5250015258789, "label": "S121", "status": "available", "price": 0, "category": "standard"},
      {"id": 129, "x": 248, "y": 559.5250015258789, "label": "S122", "status": "available", "price": 0, "category": "standard"},
      {"id": 130, "x": 288, "y": 559.5250015258789, "label": "S123", "status": "available", "price": 0, "category": "standard"},
      {"id": 131, "x": 328, "y": 559.5250015258789, "label": "S124", "status": "available", "price": 0, "category": "standard"},
      {"id": 132, "x": 223, "y": 606.5250015258789, "label": "S125", "status": "available", "price": 0, "category": "standard"},
      {"id": 133, "x": 263, "y": 606.5250015258789, "label": "S126", "status": "available", "price": 0, "category": "standard"},
      {"id": 134, "x": 303, "y": 606.5250015258789, "label": "S127", "status": "available", "price": 0, "category": "standard"},
      {"id": 135, "x": 343, "y": 606.5250015258789, "label": "S128", "status": "available", "price": 0, "category": "standard"},
      {"id": 136, "x": 714.6666666666663, "y": 78.79165818956163, "label": "S129", "status": "available", "price": 0, "category": "standard"},
      {"id": 137, "x": 754.6666666666663, "y": 78.79165818956163, "label": "S130", "status": "available", "price": 0, "category": "standard"},
      {"id": 138, "x": 732.6666666666663, "y": 128.52499389648438, "label": "S131", "status": "available", "price": 0, "category": "standard"},
      {"id": 139, "x": 772.6666666666663, "y": 128.52499389648438, "label": "S132", "status": "available", "price": 0, "category": "standard"},
      {"id": 140, "x": 747.0186666666668, "y": 173.63610500759546, "label": "S133", "status": "available", "price": 0, "category": "standard"},
      {"id": 141, "x": 787.0186666666668, "y": 173.63610500759546, "label": "S134", "status": "available", "price": 0, "category": "standard"},
      {"id": 142, "x": 759.6666666666669, "y": 226.6361050075955, "label": "S135", "status": "available", "price": 0, "category": "standard"},
      {"id": 143, "x": 799.6666666666669, "y": 226.6361050075955, "label": "S136", "status": "available", "price": 0, "category": "standard"},
      {"id": 145, "x": 1127, "y": 71.7805482369882, "label": "S138", "status": "available", "price": 0, "category": "standard"},
      {"id": 146, "x": 1167, "y": 71.7805482369882, "label": "S139", "status": "available", "price": 0, "category": "standard"},
      {"id": 147, "x": 1207, "y": 71.7805482369882, "label": "S140", "status": "available", "price": 0, "category": "standard"},
      {"id": 148, "x": 1247, "y": 71.7805482369882, "label": "S141", "status": "available", "price": 0, "category": "standard"},
      {"id": 149, "x": 1287, "y": 71.7805482369882, "label": "S142", "status": "available", "price": 0, "category": "standard"},
      {"id": 150, "x": 1327, "y": 71.7805482369882, "label": "S142", "status": "available", "price": 0, "category": "standard"},
      {"id": 151, "x": 1127, "y": 121.78054823698818, "label": "S143", "status": "available", "price": 0, "category": "standard"},
      {"id": 152, "x": 1167, "y": 121.78054823698818, "label": "S144", "status": "available", "price": 0, "category": "standard"},
      {"id": 153, "x": 1207, "y": 121.78054823698818, "label": "S145", "status": "available", "price": 0, "category": "standard"},
      {"id": 154, "x": 1247, "y": 121.78054823698818, "label": "S146", "status": "available", "price": 0, "category": "standard"},
      {"id": 155, "x": 1287, "y": 121.78054823698818, "label": "S147", "status": "available", "price": 0, "category": "standard"},
      {"id": 156, "x": 1327, "y": 121.78054823698818, "label": "S148", "status": "available", "price": 0, "category": "standard"},
      {"id": 157, "x": 1127, "y": 171.78054823698818, "label": "S149", "status": "available", "price": 0, "category": "standard"},
      {"id": 158, "x": 1167, "y": 171.78054823698818, "label": "S150", "status": "available", "price": 0, "category": "standard"},
      {"id": 159, "x": 1207, "y": 171.78054823698818, "label": "S151", "status": "available", "price": 0, "category": "standard"},
      {"id": 160, "x": 1247, "y": 171.78054823698818, "label": "S152", "status": "available", "price": 0, "category": "standard"},
      {"id": 161, "x": 1287, "y": 171.78054823698818, "label": "S153", "status": "available", "price": 0, "category": "standard"},
      {"id": 162, "x": 1327, "y": 171.78054823698818, "label": "S154", "status": "available", "price": 0, "category": "standard"},
      {"id": 163, "x": 1127, "y": 221.78054823698818, "label": "S155", "status": "available", "price": 0, "category": "standard"},
      {"id": 164, "x": 1167, "y": 221.78054823698818, "label": "S156", "status": "available", "price": 0, "category": "standard"},
      {"id": 165, "x": 1207, "y": 221.78054823698818, "label": "S157", "status": "available", "price": 0, "category": "standard"},
      {"id": 166, "x": 1247, "y": 221.78054823698818, "label": "S158", "status": "available", "price": 0, "category": "standard"},
      {"id": 167, "x": 1287, "y": 221.78054823698818, "label": "S159", "status": "available", "price": 0, "category": "standard"},
      {"id": 168, "x": 1327, "y": 221.78054823698818, "label": "S160", "status": "available", "price": 0, "category": "standard"},
      {"id": 172, "x": 1691, "y": 73.16944291856554, "label": "S161", "status": "available", "price": 0, "category": "standard"},
      {"id": 173, "x": 1731, "y": 73.16944291856554, "label": "S162", "status": "available", "price": 0, "category": "standard"},
      {"id": 174, "x": 1771, "y": 73.16944291856554, "label": "S163", "status": "available", "price": 0, "category": "standard"},
      {"id": 175, "x": 1811, "y": 73.16944291856554, "label": "S164", "status": "available", "price": 0, "category": "standard"},
      {"id": 176, "x": 1851, "y": 73.16944291856554, "label": "S165", "status": "available", "price": 0, "category": "standard"},
      {"id": 177, "x": 1891, "y": 73.16944291856554, "label": "S166", "status": "available", "price": 0, "category": "standard"},
      {"id": 178, "x": 1931, "y": 73.16944291856554, "label": "S167", "status": "available", "price": 0, "category": "standard"},
      {"id": 179, "x": 1971, "y": 73.16944291856554, "label": "S168", "status": "available", "price": 0, "category": "standard"},
      {"id": 180, "x": 2011, "y": 73.16944291856554, "label": "S169", "status": "available", "price": 0, "category": "standard"},
      {"id": 181, "x": 1685, "y": 123.16944291856555, "label": "S170", "status": "available", "price": 0, "category": "standard"},
      {"id": 182, "x": 1725, "y": 123.16944291856555, "label": "S171", "status": "available", "price": 0, "category": "standard"},
      {"id": 183, "x": 1765, "y": 123.16944291856555, "label": "S172", "status": "available", "price": 0, "category": "standard"},
      {"id": 184, "x": 1805, "y": 123.16944291856555, "label": "S173", "status": "available", "price": 0, "category": "standard"},
      {"id": 185, "x": 1845, "y": 123.16944291856555, "label": "S174", "status": "available", "price": 0, "category": "standard"},
      {"id": 186, "x": 1885, "y": 123.16944291856555, "label": "S175", "status": "available", "price": 0, "category": "standard"},
      {"id": 187, "x": 1925, "y": 123.16944291856555, "label": "S176", "status": "available", "price": 0, "category": "standard"},
      {"id": 188, "x": 1965, "y": 123.16944291856555, "label": "S177", "status": "available", "price": 0, "category": "standard"},
      {"id": 189, "x": 2005, "y": 123.16944291856555, "label": "S178", "status": "available", "price": 0, "category": "standard"},
      {"id": 190, "x": 1677, "y": 172.16944291856555, "label": "S179", "status": "available", "price": 0, "category": "standard"},
      {"id": 191, "x": 1717, "y": 172.16944291856555, "label": "S180", "status": "available", "price": 0, "category": "standard"},
      {"id": 192, "x": 1757, "y": 172.16944291856555, "label": "S181", "status": "available", "price": 0, "category": "standard"},
      {"id": 193, "x": 1797, "y": 172.16944291856555, "label": "S182", "status": "available", "price": 0, "category": "standard"},
      {"id": 194, "x": 1837, "y": 172.16944291856555, "label": "S183", "status": "available", "price": 0, "category": "standard"},
      {"id": 195, "x": 1877, "y": 172.16944291856555, "label": "S184", "status": "available", "price": 0, "category": "standard"},
      {"id": 196, "x": 1917, "y": 172.16944291856555, "label": "S185", "status": "available", "price": 0, "category": "standard"},
      {"id": 197, "x": 1957, "y": 172.16944291856555, "label": "S186", "status": "available", "price": 0, "category": "standard"},
      {"id": 198, "x": 1997, "y": 172.16944291856555, "label": "S187", "status": "available", "price": 0, "category": "standard"},
      {"id": 199, "x": 1666, "y": 220.16944291856555, "label": "S188", "status": "available", "price": 0, "category": "standard"},
      {"id": 200, "x": 1706, "y": 220.16944291856555, "label": "S189", "status": "available", "price": 0, "category": "standard"},
      {"id": 201, "x": 1746, "y": 220.16944291856555, "label": "S190", "status": "available", "price": 0, "category": "standard"},
      {"id": 202, "x": 1786, "y": 220.16944291856555, "label": "S191", "status": "available", "price": 0, "category": "standard"},
      {"id": 203, "x": 1826, "y": 220.16944291856555, "label": "S192", "status": "available", "price": 0, "category": "standard"},
      {"id": 204, "x": 1866, "y": 220.16944291856555, "label": "S193", "status": "available", "price": 0, "category": "standard"},
      {"id": 205, "x": 1906, "y": 220.16944291856555, "label": "S194", "status": "available", "price": 0, "category": "standard"},
      {"id": 206, "x": 1946, "y": 220.16944291856555, "label": "S195", "status": "available", "price": 0, "category": "standard"},
      {"id": 207, "x": 1986, "y": 220.16944291856555, "label": "S196", "status": "available", "price": 0, "category": "standard"},
      {"id": 208, "x": 1496, "y": 366.30961432823767, "label": "S197", "status": "available", "price": 0, "category": "standard"},
      {"id": 209, "x": 1536, "y": 366.30961432823767, "label": "S198", "status": "available", "price": 0, "category": "standard"},
      {"id": 210, "x": 1576, "y": 366.30961432823767, "label": "S199", "status": "available", "price": 0, "category": "standard"},
      {"id": 211, "x": 1616, "y": 366.30961432823767, "label": "S200", "status": "available", "price": 0, "category": "standard"},
      {"id": 212, "x": 1656, "y": 366.30961432823767, "label": "S201", "status": "available", "price": 0, "category": "standard"},
      {"id": 213, "x": 1696, "y": 366.30961432823767, "label": "S202", "status": "available", "price": 0, "category": "standard"},
      {"id": 214, "x": 1736, "y": 366.30961432823767, "label": "S203", "status": "available", "price": 0, "category": "standard"},
      {"id": 215, "x": 1776, "y": 366.30961432823767, "label": "S204", "status": "available", "price": 0, "category": "standard"},
      {"id": 216, "x": 1816, "y": 366.30961432823767, "label": "S205", "status": "available", "price": 0, "category": "standard"},
      {"id": 217, "x": 1856, "y": 366.30961432823767, "label": "S206", "status": "available", "price": 0, "category": "standard"},
      {"id": 218, "x": 1896, "y": 366.30961432823767, "label": "S207", "status": "available", "price": 0, "category": "standard"},
      {"id": 219, "x": 1936, "y": 366.30961432823767, "label": "S208", "status": "available", "price": 0, "category": "standard"},
      {"id": 220, "x": 1976, "y": 366.30961432823767, "label": "S209", "status": "available", "price": 0, "category": "standard"},
      {"id": 221, "x": 1487, "y": 414.30961432823767, "label": "S210", "status": "available", "price": 0, "category": "standard"},
      {"id": 222, "x": 1527, "y": 414.30961432823767, "label": "S211", "status": "available", "price": 0, "category": "standard"},
      {"id": 223, "x": 1567, "y": 414.30961432823767, "label": "S212", "status": "available", "price": 0, "category": "standard"},
      {"id": 224, "x": 1607, "y": 414.30961432823767, "label": "S213", "status": "available", "price": 0, "category": "standard"},
      {"id": 225, "x": 1647, "y": 414.30961432823767, "label": "S214", "status": "available", "price": 0, "category": "standard"},
      {"id": 226, "x": 1687, "y": 414.30961432823767, "label": "S215", "status": "available", "price": 0, "category": "standard"},
      {"id": 227, "x": 1727, "y": 414.30961432823767, "label": "S216", "status": "available", "price": 0, "category": "standard"},
      {"id": 228, "x": 1767, "y": 414.30961432823767, "label": "S217", "status": "available", "price": 0, "category": "standard"},
      {"id": 229, "x": 1807, "y": 414.30961432823767, "label": "S218", "status": "available", "price": 0, "category": "standard"},
      {"id": 230, "x": 1847, "y": 414.30961432823767, "label": "S219", "status": "available", "price": 0, "category": "standard"},
      {"id": 231, "x": 1887, "y": 414.30961432823767, "label": "S220", "status": "available", "price": 0, "category": "standard"},
      {"id": 232, "x": 1927, "y": 414.30961432823767, "label": "S221", "status": "available", "price": 0, "category": "standard"},
      {"id": 233, "x": 1967, "y": 414.30961432823767, "label": "S222", "status": "available", "price": 0, "category": "standard"},
      {"id": 234, "x": 1481, "y": 462.30961432823767, "label": "S223", "status": "available", "price": 0, "category": "standard"},
      {"id": 235, "x": 1521, "y": 462.30961432823767, "label": "S224", "status": "available", "price": 0, "category": "standard"},
      {"id": 236, "x": 1561, "y": 462.30961432823767, "label": "S225", "status": "available", "price": 0, "category": "standard"},
      {"id": 237, "x": 1601, "y": 462.30961432823767, "label": "S226", "status": "available", "price": 0, "category": "standard"},
      {"id": 238, "x": 1641, "y": 462.30961432823767, "label": "S227", "status": "available", "price": 0, "category": "standard"},
      {"id": 239, "x": 1681, "y": 462.30961432823767, "label": "S228", "status": "available", "price": 0, "category": "standard"},
      {"id": 240, "x": 1721, "y": 462.30961432823767, "label": "S229", "status": "available", "price": 0, "category": "standard"},
      {"id": 241, "x": 1761, "y": 462.30961432823767, "label": "S230", "status": "available", "price": 0, "category": "standard"},
      {"id": 242, "x": 1801, "y": 462.30961432823767, "label": "S231", "status": "available", "price": 0, "category": "standard"},
      {"id": 243, "x": 1841, "y": 462.30961432823767, "label": "S232", "status": "available", "price": 0, "category": "standard"},
      {"id": 246, "x": 1881, "y": 462.30961432823767, "label": "S233", "status": "available", "price": 0, "category": "standard"},
      {"id": 247, "x": 1921, "y": 462.30961432823767, "label": "S234", "status": "available", "price": 0, "category": "standard"},
      {"id": 248, "x": 1961, "y": 462.30961432823767, "label": "S235", "status": "available", "price": 0, "category": "standard"},
      {"id": 249, "x": 1473, "y": 510.30961432823767, "label": "S236", "status": "available", "price": 0, "category": "standard"},
      {"id": 250, "x": 1513, "y": 510.30961432823767, "label": "S237", "status": "available", "price": 0, "category": "standard"},
      {"id": 251, "x": 1553, "y": 510.30961432823767, "label": "S238", "status": "available", "price": 0, "category": "standard"},
      {"id": 252, "x": 1593, "y": 510.30961432823767, "label": "S239", "status": "available", "price": 0, "category": "standard"},
      {"id": 253, "x": 1633, "y": 510.30961432823767, "label": "S240", "status": "available", "price": 0, "category": "standard"},
      {"id": 254, "x": 1673, "y": 510.30961432823767, "label": "S241", "status": "available", "price": 0, "category": "standard"},
      {"id": 255, "x": 1713, "y": 510.30961432823767, "label": "S242", "status": "available", "price": 0, "category": "standard"},
      {"id": 256, "x": 1753, "y": 510.30961432823767, "label": "S243", "status": "available", "price": 0, "category": "standard"},
      {"id": 257, "x": 1793, "y": 510.30961432823767, "label": "S244", "status": "available", "price": 0, "category": "standard"},
      {"id": 258, "x": 1833, "y": 510.30961432823767, "label": "S245", "status": "available", "price": 0, "category": "standard"},
      {"id": 259, "x": 1873, "y": 510.30961432823767, "label": "S246", "status": "available", "price": 0, "category": "standard"},
      {"id": 260, "x": 1913, "y": 510.30961432823767, "label": "S247", "status": "available", "price": 0, "category": "standard"},
      {"id": 261, "x": 1953, "y": 510.30961432823767, "label": "S248", "status": "available", "price": 0, "category": "standard"},
      {"id": 262, "x": 599, "y": 699.8250122070312, "label": "S249", "status": "available", "price": 0, "category": "standard"},
      {"id": 263, "x": 639, "y": 699.8250122070312, "label": "S250", "status": "available", "price": 0, "category": "standard"},
      {"id": 264, "x": 679, "y": 699.8250122070312, "label": "S251", "status": "available", "price": 0, "category": "standard"},
      {"id": 265, "x": 719, "y": 699.8250122070312, "label": "S252", "status": "available", "price": 0, "category": "standard"},
      {"id": 266, "x": 759, "y": 699.8250122070312, "label": "S253", "status": "available", "price": 0, "category": "standard"},
      {"id": 267, "x": 799, "y": 699.8250122070312, "label": "S254", "status": "available", "price": 0, "category": "standard"},
      {"id": 268, "x": 839, "y": 699.8250122070312, "label": "S255", "status": "available", "price": 0, "category": "standard"},
      {"id": 269, "x": 879, "y": 699.8250122070312, "label": "S256", "status": "available", "price": 0, "category": "standard"},
      {"id": 270, "x": 919, "y": 699.8250122070312, "label": "S257", "status": "available", "price": 0, "category": "standard"},
      {"id": 271, "x": 959, "y": 699.8250122070312, "label": "S258", "status": "available", "price": 0, "category": "standard"},
      {"id": 272, "x": 603, "y": 751.2850097656249, "label": "S259", "status": "available", "price": 0, "category": "standard"},
      {"id": 273, "x": 643, "y": 751.2850097656249, "label": "S260", "status": "available", "price": 0, "category": "standard"},
      {"id": 275, "x": 723, "y": 751.2850097656249, "label": "S262", "status": "available", "price": 0, "category": "standard"},
      {"id": 276, "x": 763, "y": 751.2850097656249, "label": "S263", "status": "available", "price": 0, "category": "standard"},
      {"id": 277, "x": 803, "y": 751.2850097656249, "label": "S264", "status": "available", "price": 0, "category": "standard"},
      {"id": 278, "x": 843, "y": 751.2850097656249, "label": "S265", "status": "available", "price": 0, "category": "standard"},
      {"id": 279, "x": 883, "y": 751.2850097656249, "label": "S266", "status": "available", "price": 0, "category": "standard"},
      {"id": 280, "x": 923, "y": 751.2850097656249, "label": "S267", "status": "available", "price": 0, "category": "standard"},
      {"id": 281, "x": 963, "y": 751.2850097656249, "label": "S268", "status": "available", "price": 0, "category": "standard"},
      {"id": 282, "x": 604, "y": 799.8250122070312, "label": "S269", "status": "available", "price": 0, "category": "standard"},
      {"id": 283, "x": 644, "y": 799.8250122070312, "label": "S270", "status": "available", "price": 0, "category": "standard"},
      {"id": 284, "x": 684, "y": 799.8250122070312, "label": "S271", "status": "available", "price": 0, "category": "standard"},
      {"id": 285, "x": 724, "y": 799.8250122070312, "label": "S272", "status": "available", "price": 0, "category": "standard"},
      {"id": 286, "x": 764, "y": 799.8250122070312, "label": "S273", "status": "available", "price": 0, "category": "standard"},
      {"id": 287, "x": 804, "y": 799.8250122070312, "label": "S274", "status": "available", "price": 0, "category": "standard"},
      {"id": 288, "x": 844, "y": 799.8250122070312, "label": "S275", "status": "available", "price": 0, "category": "standard"},
      {"id": 289, "x": 884, "y": 799.8250122070312, "label": "S276", "status": "available", "price": 0, "category": "standard"},
      {"id": 290, "x": 924, "y": 799.8250122070312, "label": "S277", "status": "available", "price": 0, "category": "standard"},
      {"id": 291, "x": 964, "y": 799.8250122070312, "label": "S278", "status": "available", "price": 0, "category": "standard"},
      {"id": 292, "x": 683, "y": 751.2850097656249, "label": "S278", "status": "available", "price": 0, "category": "standard"},
      {"id": 293, "x": 754, "y": 646.2678571428571, "label": "S279", "status": "available", "price": 0, "category": "standard"},
      {"id": 294, "x": 794, "y": 646.2678571428571, "label": "S280", "status": "available", "price": 0, "category": "standard"},
      {"id": 295, "x": 834, "y": 646.2678571428571, "label": "S281", "status": "available", "price": 0, "category": "standard"},
      {"id": 296, "x": 874, "y": 646.2678571428571, "label": "S282", "status": "available", "price": 0, "category": "standard"},
      {"id": 297, "x": 914, "y": 646.2678571428571, "label": "S283", "status": "available", "price": 0, "category": "standard"},
      {"id": 298, "x": 954, "y": 646.2678571428571, "label": "S284", "status": "available", "price": 0, "category": "standard"},
      {"id": 299, "x": 714, "y": 646.2678571428571, "label": "S285", "status": "available", "price": 0, "category": "standard"},
      {"id": 300, "x": 2256, "y": 75.16944291856555, "label": "S286", "status": "available", "price": 0, "category": "standard"},
      {"id": 301, "x": 2296, "y": 75.16944291856555, "label": "S287", "status": "available", "price": 0, "category": "standard"},
      {"id": 302, "x": 2336, "y": 75.16944291856555, "label": "S288", "status": "available", "price": 0, "category": "standard"},
      {"id": 303, "x": 2376, "y": 75.16944291856555, "label": "S289", "status": "available", "price": 0, "category": "standard"},
      {"id": 304, "x": 2248, "y": 123.16944291856555, "label": "S290", "status": "available", "price": 0, "category": "standard"},
      {"id": 305, "x": 2288, "y": 123.16944291856555, "label": "S291", "status": "available", "price": 0, "category": "standard"},
      {"id": 306, "x": 2328, "y": 123.16944291856555, "label": "S292", "status": "available", "price": 0, "category": "standard"},
      {"id": 307, "x": 2368, "y": 123.16944291856555, "label": "S293", "status": "available", "price": 0, "category": "standard"},
      {"id": 308, "x": 2240, "y": 171.16944291856555, "label": "S294", "status": "available", "price": 0, "category": "standard"},
      {"id": 309, "x": 2280, "y": 171.16944291856555, "label": "S295", "status": "available", "price": 0, "category": "standard"},
      {"id": 310, "x": 2320, "y": 171.16944291856555, "label": "S296", "status": "available", "price": 0, "category": "standard"},
      {"id": 311, "x": 2360, "y": 171.16944291856555, "label": "S297", "status": "available", "price": 0, "category": "standard"},
      {"id": 312, "x": 2234, "y": 220.16944291856555, "label": "S298", "status": "available", "price": 0, "category": "standard"},
      {"id": 313, "x": 2274, "y": 220.16944291856555, "label": "S299", "status": "available", "price": 0, "category": "standard"},
      {"id": 314, "x": 2314, "y": 220.16944291856555, "label": "S300", "status": "available", "price": 0, "category": "standard"},
      {"id": 315, "x": 2354, "y": 220.16944291856555, "label": "S301", "status": "available", "price": 0, "category": "standard"},
      {"id": 316, "x": 2230, "y": 268.16944291856555, "label": "S302", "status": "available", "price": 0, "category": "standard"},
      {"id": 317, "x": 2270, "y": 268.16944291856555, "label": "S303", "status": "available", "price": 0, "category": "standard"},
      {"id": 318, "x": 2310, "y": 268.16944291856555, "label": "S304", "status": "available", "price": 0, "category": "standard"},
      {"id": 319, "x": 2350, "y": 268.16944291856555, "label": "S305", "status": "available", "price": 0, "category": "standard"},
      {"id": 320, "x": 2221, "y": 312.16944291856555, "label": "S306", "status": "available", "price": 0, "category": "standard"},
      {"id": 321, "x": 2261, "y": 312.16944291856555, "label": "S307", "status": "available", "price": 0, "category": "standard"},
      {"id": 322, "x": 2301, "y": 312.16944291856555, "label": "S308", "status": "available", "price": 0, "category": "standard"},
      {"id": 323, "x": 2341, "y": 312.16944291856555, "label": "S309", "status": "available", "price": 0, "category": "standard"},
      {"id": 324, "x": 2178, "y": 362.9605543348524, "label": "S310", "status": "available", "price": 0, "category": "standard"},
      {"id": 325, "x": 2218, "y": 362.9605543348524, "label": "S311", "status": "available", "price": 0, "category": "standard"},
      {"id": 326, "x": 2258, "y": 362.9605543348524, "label": "S312", "status": "available", "price": 0, "category": "standard"},
      {"id": 327, "x": 2298, "y": 362.9605543348524, "label": "S313", "status": "available", "price": 0, "category": "standard"},
      {"id": 328, "x": 2168, "y": 411.3605543348524, "label": "S314", "status": "available", "price": 0, "category": "standard"},
      {"id": 329, "x": 2208, "y": 411.3605543348524, "label": "S315", "status": "available", "price": 0, "category": "standard"},
      {"id": 330, "x": 2248, "y": 411.3605543348524, "label": "S316", "status": "available", "price": 0, "category": "standard"},
      {"id": 331, "x": 2288, "y": 411.3605543348524, "label": "S317", "status": "available", "price": 0, "category": "standard"},
      {"id": 332, "x": 2156, "y": 462.16055433485246, "label": "S318", "status": "available", "price": 0, "category": "standard"},
      {"id": 333, "x": 2196, "y": 462.16055433485246, "label": "S319", "status": "available", "price": 0, "category": "standard"},
      {"id": 334, "x": 2236, "y": 462.16055433485246, "label": "S320", "status": "available", "price": 0, "category": "standard"},
      {"id": 335, "x": 2276, "y": 462.16055433485246, "label": "S321", "status": "available", "price": 0, "category": "standard"},
      {"id": 336, "x": 2149, "y": 513.520551893446, "label": "S322", "status": "available", "price": 0, "category": "standard"},
      {"id": 337, "x": 2189, "y": 513.520551893446, "label": "S323", "status": "available", "price": 0, "category": "standard"},
      {"id": 338, "x": 2229, "y": 513.520551893446, "label": "S324", "status": "available", "price": 0, "category": "standard"},
      {"id": 339, "x": 2269, "y": 513.520551893446, "label": "S325", "status": "available", "price": 0, "category": "standard"},
      {"id": 340, "x": 2141, "y": 562.7205518934461, "label": "S326", "status": "available", "price": 0, "category": "standard"},
      {"id": 341, "x": 2181, "y": 562.7205518934461, "label": "S327", "status": "available", "price": 0, "category": "standard"},
      {"id": 342, "x": 2221, "y": 562.7205518934461, "label": "S328", "status": "available", "price": 0, "category": "standard"},
      {"id": 343, "x": 2261, "y": 562.7205518934461, "label": "S329", "status": "available", "price": 0, "category": "standard"},
      {"id": 344, "x": 2134, "y": 610.5605543348524, "label": "S330", "status": "available", "price": 0, "category": "standard"},
      {"id": 345, "x": 2174, "y": 610.5605543348524, "label": "S331", "status": "available", "price": 0, "category": "standard"},
      {"id": 346, "x": 2214, "y": 610.5605543348524, "label": "S332", "status": "available", "price": 0, "category": "standard"},
      {"id": 347, "x": 2254, "y": 610.5605543348524, "label": "S333", "status": "available", "price": 0, "category": "standard"},
      {"id": 348, "x": 2127, "y": 664.3605543348524, "label": "S334", "status": "available", "price": 0, "category": "standard"},
      {"id": 349, "x": 2167, "y": 664.3605543348524, "label": "S335", "status": "available", "price": 0, "category": "standard"},
      {"id": 350, "x": 2207, "y": 664.3605543348524, "label": "S336", "status": "available", "price": 0, "category": "standard"},
      {"id": 351, "x": 2247, "y": 664.3605543348524, "label": "S337", "status": "available", "price": 0, "category": "standard"},
      {"id": 352, "x": 2118, "y": 711.7605543348523, "label": "S338", "status": "available", "price": 0, "category": "standard"},
      {"id": 353, "x": 2158, "y": 711.7605543348523, "label": "S339", "status": "available", "price": 0, "category": "standard"},
      {"id": 354, "x": 2198, "y": 711.7605543348523, "label": "S340", "status": "available", "price": 0, "category": "standard"},
      {"id": 355, "x": 2238, "y": 711.7605543348523, "label": "S341", "status": "available", "price": 0, "category": "standard"},
      {"id": 356, "x": 2114, "y": 756.7605543348523, "label": "S342", "status": "available", "price": 0, "category": "standard"},
      {"id": 357, "x": 2154, "y": 756.7605543348523, "label": "S343", "status": "available", "price": 0, "category": "standard"},
      {"id": 358, "x": 2194, "y": 756.7605543348523, "label": "S344", "status": "available", "price": 0, "category": "standard"},
      {"id": 359, "x": 2234, "y": 756.7605543348523, "label": "S345", "status": "available", "price": 0, "category": "standard"},
      {"id": 360, "x": 2107, "y": 804.1605543348523, "label": "S346", "status": "available", "price": 0, "category": "standard"},
      {"id": 361, "x": 2147, "y": 804.1605543348523, "label": "S347", "status": "available", "price": 0, "category": "standard"},
      {"id": 362, "x": 2187, "y": 804.1605543348523, "label": "S348", "status": "available", "price": 0, "category": "standard"},
      {"id": 363, "x": 2227, "y": 804.1605543348523, "label": "S349", "status": "available", "price": 0, "category": "standard"},
      {"id": 364, "x": 2267, "y": 804.1605543348523, "label": "S350", "status": "available", "price": 0, "category": "standard"},
      {"id": 365, "x": 2274, "y": 756.7605543348523, "label": "S351", "status": "available", "price": 0, "category": "standard"},
      {"id": 366, "x": 2278, "y": 711.7605543348523, "label": "S352", "status": "available", "price": 0, "category": "standard"},
      {"id": 367, "x": 2287, "y": 664.3605543348524, "label": "S353", "status": "available", "price": 0, "category": "standard"},
      {"id": 368, "x": 2294, "y": 610.5605543348524, "label": "S354", "status": "available", "price": 0, "category": "standard"},
      {"id": 369, "x": 2301, "y": 562.7205518934461, "label": "S355", "status": "available", "price": 0, "category": "standard"},
      {"id": 370, "x": 2309, "y": 513.520551893446, "label": "S356", "status": "available", "price": 0, "category": "standard"},
      {"id": 371, "x": 2316, "y": 462.16055433485246, "label": "S357", "status": "available", "price": 0, "category": "standard"},
      {"id": 372, "x": 2328, "y": 411.3605543348524, "label": "S358", "status": "available", "price": 0, "category": "standard"},
      {"id": 373, "x": 2338, "y": 362.9605543348524, "label": "S359", "status": "available", "price": 0, "category": "standard"},
      {"id": 374, "x": 1801, "y": 650.7605543348523, "label": "S360", "status": "available", "price": 0, "category": "standard"},
      {"id": 375, "x": 1841, "y": 650.7605543348523, "label": "S361", "status": "available", "price": 0, "category": "standard"},
      {"id": 376, "x": 1881, "y": 650.7605543348523, "label": "S362", "status": "available", "price": 0, "category": "standard"},
      {"id": 377, "x": 1921, "y": 650.7605543348523, "label": "S363", "status": "available", "price": 0, "category": "standard"},
      {"id": 378, "x": 1792, "y": 699.7605543348523, "label": "S364", "status": "available", "price": 0, "category": "standard"},
      {"id": 379, "x": 1832, "y": 699.7605543348523, "label": "S365", "status": "available", "price": 0, "category": "standard"},
      {"id": 380, "x": 1872, "y": 699.7605543348523, "label": "S366", "status": "available", "price": 0, "category": "standard"},
      {"id": 381, "x": 1912, "y": 699.7605543348523, "label": "S367", "status": "available", "price": 0, "category": "standard"},
      {"id": 382, "x": 1787, "y": 750.7605543348523, "label": "S368", "status": "available", "price": 0, "category": "standard"},
      {"id": 383, "x": 1827, "y": 750.7605543348523, "label": "S369", "status": "available", "price": 0, "category": "standard"},
      {"id": 384, "x": 1867, "y": 750.7605543348523, "label": "S370", "status": "available", "price": 0, "category": "standard"},
      {"id": 385, "x": 1907, "y": 750.7605543348523, "label": "S371", "status": "available", "price": 0, "category": "standard"},
      {"id": 387, "x": 1781, "y": 798.7605543348523, "label": "S373", "status": "available", "price": 0, "category": "standard"},
      {"id": 388, "x": 1821, "y": 798.7605543348523, "label": "S374", "status": "available", "price": 0, "category": "standard"},
      {"id": 389, "x": 1861, "y": 798.7605543348523, "label": "S375", "status": "available", "price": 0, "category": "standard"},
      {"id": 390, "x": 1901, "y": 798.7605543348523, "label": "S376", "status": "available", "price": 0, "category": "standard"}
    ],
    "sections": [],
    "textElements": [],
    "imageElements": [],
    "nextSeatId": 392,
    "nextSectionId": 1,
    "nextTextId": 1,
    "nextImageId": 1,
    "exportedAt": "2025-04-23T10:40:19.476Z"
  };
}

// ==================== PAINTER DU SIÈGE ====================

class SeatPainter extends CustomPainter {
  final String label;
  final String status;
  final bool isSelected;
  final double price;

  SeatPainter({
    required this.label,
    required this.status,
    required this.isSelected,
    required this.price,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Couleurs selon le statut
    Color backrestColor;
    if (isSelected) {
      backrestColor = const Color(0xFF4CAF50);
    } else if (status == 'reserved') {
      backrestColor = const Color(0xFFFFC107);
    } else if (status == 'unavailable') {
      backrestColor = const Color(0xFFF44336);
    } else {
      backrestColor = const Color(0xFF3A5BD9);
    }

    // Dégradé pour le dossier
    final backrestPaint = Paint()
      ..color = backrestColor
      ..style = PaintingStyle.fill;

    // Dossier (backrest)
    final backrestRect = Rect.fromLTWH(2, 0, width - 4, height - 12);
    final backrestPath = Path()
      ..addRRect(RRect.fromRectAndRadius(backrestRect, const Radius.circular(4)));
    canvas.drawPath(backrestPath, backrestPaint);

    // Ombre du dossier
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    canvas.drawPath(backrestPath, shadowPaint);

    // Assise (base)
    final baseRect = Rect.fromLTWH(2, height - 12, width - 4, 10);
    final basePaint = Paint()
      ..color = const Color(0xFF1A1A1A)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(baseRect, const Radius.circular(2)), basePaint);

    // Appui-tête
    final headrestRect = Rect.fromLTWH(width / 2 - 9, 2, 18, 5);
    final headrestPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(headrestRect, const Radius.circular(2)), headrestPaint);

    // Accoudoirs
    final armrestPaint = Paint()..color = const Color(0xFF222222);

    // Accoudoir gauche
    final armrestLeftRect = Rect.fromLTWH(0, height - 18, 3, 11);
    canvas.drawRRect(RRect.fromRectAndRadius(armrestLeftRect, const Radius.circular(1)), armrestPaint);

    // Accoudoir droit
    final armrestRightRect = Rect.fromLTWH(width - 3, height - 18, 3, 11);
    canvas.drawRRect(RRect.fromRectAndRadius(armrestRightRect, const Radius.circular(1)), armrestPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          fontFamily: 'Urbanist',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        height - 20,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ==================== WIDGET DU SIÈGE ====================

class SeatWidget extends StatefulWidget {
  final Seat seat;
  final Function(Seat) onTap;
  final bool isSelected;

  const SeatWidget({
    Key? key,
    required this.seat,
    required this.onTap,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(SeatWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController.forward().then((_) => _pulseController.reverse());
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isSelected ? _pulseAnimation.value : 1.0,
          child: GestureDetector(
            onTap: () => widget.onTap(widget.seat),
            child: SizedBox(
              width: 30,
              height: 34,
              child: CustomPaint(
                painter: SeatPainter(
                  label: widget.seat.label,
                  status: widget.seat.status,
                  isSelected: widget.isSelected,
                  price: widget.seat.price,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== MODAL D'INFORMATION DU SIÈGE ====================

class SeatInfoModal extends StatelessWidget {
  final Seat seat;
  final VoidCallback onBuy;

  const SeatInfoModal({
    Key? key,
    required this.seat,
    required this.onBuy,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Détails de la place',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE41E26),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.chair, 'Numéro', seat.label),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.price_change, 'Prix', '${seat.price.toStringAsFixed(2)} MAD'),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.category, 'Catégorie', seat.category),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  onBuy();
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text(
                  'Acheter cette place',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE41E26),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFE41E26)),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ==================== CARTE DES SIÈGES PRINCIPALE ====================

class SeatingMapWidget extends StatefulWidget {
  final List<Seat> seats;
  final double width;
  final double height;
  final Function(Seat) onSeatSelected;

  const SeatingMapWidget({
    Key? key,
    required this.seats,
    required this.width,
    required this.height,
    required this.onSeatSelected,
  }) : super(key: key);

  @override
  State<SeatingMapWidget> createState() => _SeatingMapWidgetState();
}

class _SeatingMapWidgetState extends State<SeatingMapWidget> {
  double _scale = 1.0;
  Offset _offset = Offset.zero;
  Seat? _selectedSeat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildLegend(),
        const SizedBox(height: 16),
        Expanded(
          child: InteractiveViewer(
            minScale: 0.3,
            maxScale: 2.0,
            constrained: false,
            onInteractionEnd: (details) {
              setState(() {});
            },
            child: Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                backgroundBlendMode: BlendMode.multiply,
                image: const DecorationImage(
                  image: NetworkImage('https://ticketing-storage-eu-west-3.s3.eu-west-3.amazonaws.com/public/uploads/stadium/background/s5oOuJ1You9IkLMYnq2gRachZsHbGZrUet3T56WS.png?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYCLBFSOSXYH3VBXU%2F20260324%2Feu-west-3%2Fs3%2Faws4_request&X-Amz-Date=20260324T222613Z&X-Amz-SignedHeaders=host&X-Amz-Expires=1800&X-Amz-Signature=f8b674be1b6b79bfb71f00c613d495f8875fbd1e4fcb0522e9b8a2d56a92579c'),
                  repeat: ImageRepeat.repeat,
                  opacity: 0.3,
                ),
              ),
              child: Stack(
                children: widget.seats.map((seat) {
                  return Positioned(
                    left: seat.x - 15,
                    top: seat.y - 17,
                    child: SeatWidget(
                      seat: seat,
                      isSelected: _selectedSeat?.id == seat.id,
                      onTap: (selectedSeat) {
                        if (seat.status == 'available') {
                          setState(() {
                            if (_selectedSeat != null) {
                              _selectedSeat!.isSelected = false;
                            }
                            _selectedSeat = selectedSeat;
                            _selectedSeat!.isSelected = true;
                          });
                          widget.onSeatSelected(selectedSeat);
                        } else {
                          _showToast(
                            seat.status == 'reserved'
                                ? 'Cette place est réservée'
                                : 'Cette place n\'est pas disponible',
                          );
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(const Color(0xFF3A5BD9), 'Disponible'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFFFFC107), 'Réservée'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFFF44336), 'Vendue'),
          const SizedBox(width: 16),
          _legendItem(const Color(0xFF4CAF50), 'Sélectionnée'),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }



  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.grey[800],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ==================== PAGE PRINCIPALE ====================

class SeatingMapPage extends StatefulWidget {
  const SeatingMapPage({Key? key}) : super(key: key);

  @override
  State<SeatingMapPage> createState() => _SeatingMapPageState();
}

class _SeatingMapPageState extends State<SeatingMapPage> {
  List<Seat> seats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    // Simuler un chargement
    await Future.delayed(const Duration(milliseconds: 500));
    final data = getSeatingData();
    setState(() {
      seats = (data['seats'] as List)
          .map((seatJson) => Seat.fromJson(seatJson))
          .toList();
      isLoading = false;
    });
  }

  void _onSeatSelected(Seat seat) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SeatInfoModal(
        seat: seat,
        onBuy: () {
          _addToCart(seat);
        },
      ),
    );
  }

  void _addToCart(Seat seat) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Place ${seat.label} ajoutée au panier'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choisissez votre place',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : const Color(0xFFE41E26),
        ),
      ),
      backgroundColor: isDarkMode ? Colors.black : Colors.grey[50],
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE41E26),
        ),
      )
          : SeatingMapWidget(
        seats: seats,
        width: 2500,
        height: 900,
        onSeatSelected: _onSeatSelected,
      ),
    );
  }
}