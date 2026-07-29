class ChecklistTemplate {
  final String id;
  String name;
  List<String> items;

  ChecklistTemplate({required this.id, required this.name, required this.items});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'items': items};

  factory ChecklistTemplate.fromJson(Map<String, dynamic> json) => ChecklistTemplate(
        id: json['id'],
        name: json['name'],
        items: List<String>.from(json['items']),
      );
}

enum ItemStatus { pass, fail, na }

class InspectionItem {
  String label;
  ItemStatus status;
  String note;

  InspectionItem({required this.label, this.status = ItemStatus.na, this.note = ''});

  Map<String, dynamic> toJson() => {'label': label, 'status': status.name, 'note': note};

  factory InspectionItem.fromJson(Map<String, dynamic> json) => InspectionItem(
        label: json['label'],
        status: ItemStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ItemStatus.na,
        ),
        note: json['note'] ?? '',
      );
}

class Inspection {
  final String id;
  String templateName;
  String clientName;
  String propertyAddress;
  DateTime date;
  List<InspectionItem> items;
  List<String> photoPaths;
  String? signaturePath;
  String generalNotes;

  Inspection({
    required this.id,
    required this.templateName,
    required this.clientName,
    required this.propertyAddress,
    required this.date,
    required this.items,
    this.photoPaths = const [],
    this.signaturePath,
    this.generalNotes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'templateName': templateName,
        'clientName': clientName,
        'propertyAddress': propertyAddress,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'photoPaths': photoPaths,
        'signaturePath': signaturePath,
        'generalNotes': generalNotes,
      };

  factory Inspection.fromJson(Map<String, dynamic> json) => Inspection(
        id: json['id'],
        templateName: json['templateName'],
        clientName: json['clientName'],
        propertyAddress: json['propertyAddress'],
        date: DateTime.parse(json['date']),
        items: (json['items'] as List)
            .map((e) => InspectionItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        photoPaths: List<String>.from(json['photoPaths'] ?? []),
        signaturePath: json['signaturePath'],
        generalNotes: json['generalNotes'] ?? '',
      );
}

class BrandingSettings {
  String companyName;
  String contactInfo;
  String terms;
  String? logoPath;

  BrandingSettings({
    this.companyName = '',
    this.contactInfo = '',
    this.terms = '',
    this.logoPath,
  });

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'contactInfo': contactInfo,
        'terms': terms,
        'logoPath': logoPath,
      };

  factory BrandingSettings.fromJson(Map<String, dynamic> json) => BrandingSettings(
        companyName: json['companyName'] ?? '',
        contactInfo: json['contactInfo'] ?? '',
        terms: json['terms'] ?? '',
        logoPath: json['logoPath'],
      );
}
