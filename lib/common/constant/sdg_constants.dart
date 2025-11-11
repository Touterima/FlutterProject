// common/constants/sdg_constants.dart
import 'dart:ui';

import 'package:flutter/material.dart';

class SdgConstants {
  static const List<String> sdgObjectives = [
    "Climate Action (CO2 Reduction)",
    "Affordable and Clean Energy",
    "Sustainable Cities and Communities", 
    "Responsible Consumption and Production",
    "Life Below Water",
    "Life on Land",
    "Clean Transportation",
    "Green Mobility",
    "Carbon Neutral Events",
    "Environmental Education",
    "Eco-Friendly Transportation",
    "Sustainable Tourism",
    "Green Infrastructure",
    "Biodiversity Protection",
    "Zero Waste Events",
    "Renewable Energy Promotion",
    "Public Transportation Advocacy",
    "Cycling and Walking Promotion",
    "Electric Vehicle Promotion",
    "Carpooling and Ridesharing"
  ];

  static const Map<String, String> sdgIcons = {
    "Climate Action (CO2 Reduction)": "🌍",
    "Affordable and Clean Energy": "⚡",
    "Sustainable Cities and Communities": "🏙️",
    "Responsible Consumption and Production": "🔄",
    "Life Below Water": "🐠",
    "Life on Land": "🌳",
    "Clean Transportation": "🚆",
    "Green Mobility": "🚲",
    "Carbon Neutral Events": "📊",
    "Environmental Education": "📚",
    "Eco-Friendly Transportation": "🚗",
    "Sustainable Tourism": "🏞️",
    "Green Infrastructure": "🏗️",
    "Biodiversity Protection": "🦋",
    "Zero Waste Events": "🗑️",
    "Renewable Energy Promotion": "☀️",
    "Public Transportation Advocacy": "🚌",
    "Cycling and Walking Promotion": "🚶",
    "Electric Vehicle Promotion": "🔋",
    "Carpooling and Ridesharing": "👥"
  };

  static const Map<String, Color> sdgColors = {
    "Climate Action (CO2 Reduction)": Colors.red,
    "Affordable and Clean Energy": Colors.yellow,
    "Sustainable Cities and Communities": Colors.orange,
    "Responsible Consumption and Production": Colors.brown,
    "Life Below Water": Colors.blue,
    "Life on Land": Colors.green,
    "Clean Transportation": Colors.cyan,
    "Green Mobility": Colors.lightGreen,
    "Carbon Neutral Events": Colors.grey,
    "Environmental Education": Colors.purple,
    "Eco-Friendly Transportation": Colors.teal,
    "Sustainable Tourism": Colors.lightBlue,
    "Green Infrastructure": Colors.blueGrey,
    "Biodiversity Protection": Colors.green,
    "Zero Waste Events": Colors.deepOrange,
    "Renewable Energy Promotion": Colors.amber,
    "Public Transportation Advocacy": Colors.indigo,
    "Cycling and Walking Promotion": Colors.lime,
    "Electric Vehicle Promotion": Colors.blue,
    "Carpooling and Ridesharing": Colors.cyan
  };

  static String getIconForSdg(String sdg) {
    return sdgIcons[sdg] ?? "🌱";
  }

  static Color getColorForSdg(String sdg) {
    return sdgColors[sdg] ?? Colors.green;
  }
}