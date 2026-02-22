import 'package:equatable/equatable.dart';

class ATSConfig extends Equatable {
  final double keywordWeight;
  final double skillWeight;
  final double grammarWeight;
  final double experienceWeight;
  final double formattingWeight;

  const ATSConfig({
    this.keywordWeight = 30,
    this.skillWeight = 25,
    this.grammarWeight = 15,
    this.experienceWeight = 20,
    this.formattingWeight = 10,
  });

  ATSConfig copyWith({
    double? keywordWeight,
    double? skillWeight,
    double? grammarWeight,
    double? experienceWeight,
    double? formattingWeight,
  }) {
    return ATSConfig(
      keywordWeight: keywordWeight ?? this.keywordWeight,
      skillWeight: skillWeight ?? this.skillWeight,
      grammarWeight: grammarWeight ?? this.grammarWeight,
      experienceWeight: experienceWeight ?? this.experienceWeight,
      formattingWeight: formattingWeight ?? this.formattingWeight,
    );
  }

  double get totalWeight =>
      keywordWeight +
      skillWeight +
      grammarWeight +
      experienceWeight +
      formattingWeight;

  @override
  List<Object?> get props => [
    keywordWeight,
    skillWeight,
    grammarWeight,
    experienceWeight,
    formattingWeight,
  ];
}
