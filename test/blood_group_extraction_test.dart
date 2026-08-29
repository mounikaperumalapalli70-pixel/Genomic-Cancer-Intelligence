import 'package:flutter_test/flutter_test.dart';
import 'package:genomic_cancer_intelligence/core/services/information_extraction_service.dart';

void main() {
  late InformationExtractionService nlp;

  setUp(() {
    nlp = InformationExtractionService();
  });

  group('Blood Group Extraction Tests', () {
    test('extracts O+ variants', () {
      expect(nlp.extractBasicInfo('O positive', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('o positive', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O+', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O +', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('Positive O', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('My blood group is O positive', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('oh positive', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O pos', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
    });

    test('extracts other positive groups', () {
      expect(nlp.extractBasicInfo('A positive', currentTargetField: 'bloodGroup').bloodGroup, 'A+');
      expect(nlp.extractBasicInfo('A+', currentTargetField: 'bloodGroup').bloodGroup, 'A+');
      expect(nlp.extractBasicInfo('Positive A', currentTargetField: 'bloodGroup').bloodGroup, 'A+');

      expect(nlp.extractBasicInfo('B positive', currentTargetField: 'bloodGroup').bloodGroup, 'B+');
      expect(nlp.extractBasicInfo('B+', currentTargetField: 'bloodGroup').bloodGroup, 'B+');
      expect(nlp.extractBasicInfo('be positive', currentTargetField: 'bloodGroup').bloodGroup, 'B+');

      expect(nlp.extractBasicInfo('AB positive', currentTargetField: 'bloodGroup').bloodGroup, 'AB+');
      expect(nlp.extractBasicInfo('AB+', currentTargetField: 'bloodGroup').bloodGroup, 'AB+');
      expect(nlp.extractBasicInfo('a b positive', currentTargetField: 'bloodGroup').bloodGroup, 'AB+');
    });

    test('extracts negative groups', () {
      expect(nlp.extractBasicInfo('O negative', currentTargetField: 'bloodGroup').bloodGroup, 'O-');
      expect(nlp.extractBasicInfo('O-', currentTargetField: 'bloodGroup').bloodGroup, 'O-');
      expect(nlp.extractBasicInfo('Negative O', currentTargetField: 'bloodGroup').bloodGroup, 'O-');

      expect(nlp.extractBasicInfo('A negative', currentTargetField: 'bloodGroup').bloodGroup, 'A-');
      expect(nlp.extractBasicInfo('A-', currentTargetField: 'bloodGroup').bloodGroup, 'A-');

      expect(nlp.extractBasicInfo('B negative', currentTargetField: 'bloodGroup').bloodGroup, 'B-');
      expect(nlp.extractBasicInfo('B-', currentTargetField: 'bloodGroup').bloodGroup, 'B-');

      expect(nlp.extractBasicInfo('AB negative', currentTargetField: 'bloodGroup').bloodGroup, 'AB-');
      expect(nlp.extractBasicInfo('AB-', currentTargetField: 'bloodGroup').bloodGroup, 'AB-');
    });

    test('extracts Indic language responses', () {
      expect(nlp.extractBasicInfo('ఓ పాజిటివ్', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O పాజిటివ్', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O பாசிட்டிவ்', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('O ಪಾಸಿಟಿವ್', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
      expect(nlp.extractBasicInfo('ओ पॉजिटिव', currentTargetField: 'bloodGroup').bloodGroup, 'O+');
    });

    test('multi-field utterance extraction with blood group', () {
      final info = nlp.extractBasicInfo(
        "My name is Charan, 21 years old, 170 cm, 65 kg and my blood group is O positive",
        currentTargetField: 'name',
      );
      expect(info.name, 'Charan');
      expect(info.age, 21);
      expect(info.heightCm, 170.0);
      expect(info.weightKg, 65.0);
      expect(info.bloodGroup, 'O+');
    });
  });
}
