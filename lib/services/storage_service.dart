import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class StorageService {
  static const _templatesBox = 'templates';
  static const _inspectionsBox = 'inspections';
  static const _settingsBox = 'settings';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_templatesBox);
    await Hive.openBox(_inspectionsBox);
    await Hive.openBox(_settingsBox);
    await _seedDefaultTemplates();
  }

  static Box get _templates => Hive.box(_templatesBox);
  static Box get _inspections => Hive.box(_inspectionsBox);
  static Box get _settings => Hive.box(_settingsBox);

  static Future<void> _seedDefaultTemplates() async {
    if (_templates.isNotEmpty) return;
    final defaults = [
      ChecklistTemplate(id: 'move_in_out', name: 'Move-In / Move-Out', items: [
        'Walls & Paint',
        'Flooring',
        'Windows & Screens',
        'Doors & Locks',
        'Kitchen Appliances',
        'Plumbing Fixtures',
        'Electrical Outlets',
        'Smoke Detectors',
        'Overall Cleanliness',
      ]),
      ChecklistTemplate(id: 'hvac', name: 'HVAC Maintenance', items: [
        'Air Filter Condition',
        'Thermostat Operation',
        'Refrigerant Lines',
        'Condenser Coil',
        'Evaporator Coil',
        'Ductwork',
        'Condensate Drain Line',
        'Electrical Connections',
        'Airflow Test',
      ]),
      ChecklistTemplate(id: 'roof', name: 'Roof Inspection', items: [
        'Shingles / Tiles Condition',
        'Flashing',
        'Gutters & Downspouts',
        'Chimney',
        'Roof Vents',
        'Signs of Leaks',
        'Structural Sagging',
      ]),
      ChecklistTemplate(id: 'electrical', name: 'Electrical Safety', items: [
        'Panel Condition',
        'Breakers Labeled',
        'GFCI Outlets',
        'Wiring Condition',
        'Grounding',
        'Fixture Condition',
        'Exposed Wiring',
      ]),
    ];
    for (final t in defaults) {
      await _templates.put(t.id, t.toJson());
    }
  }

  static List<ChecklistTemplate> getTemplates() => _templates.values
      .map((e) => ChecklistTemplate.fromJson(Map<String, dynamic>.from(e)))
      .toList();

  static Future<void> saveTemplate(ChecklistTemplate t) => _templates.put(t.id, t.toJson());

  static Future<void> deleteTemplate(String id) => _templates.delete(id);

  static List<Inspection> getInspections() => _inspections.values
      .map((e) => Inspection.fromJson(Map<String, dynamic>.from(e)))
      .toList()
    ..sort((a, b) => b.date.compareTo(a.date));

  static Future<void> saveInspection(Inspection i) => _inspections.put(i.id, i.toJson());

  static Future<void> deleteInspection(String id) => _inspections.delete(id);

  static BrandingSettings getBranding() {
    final raw = _settings.get('branding');
    if (raw == null) return BrandingSettings();
    return BrandingSettings.fromJson(Map<String, dynamic>.from(raw));
  }

  static Future<void> saveBranding(BrandingSettings b) => _settings.put('branding', b.toJson());
}
