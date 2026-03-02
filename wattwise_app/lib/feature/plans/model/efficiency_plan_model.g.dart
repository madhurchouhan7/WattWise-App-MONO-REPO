// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'efficiency_plan_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EfficiencyPlanModel _$EfficiencyPlanModelFromJson(Map<String, dynamic> json) =>
    _EfficiencyPlanModel(
      summary: json['summary'] as String,
      estimatedCurrentMonthlyCost: (json['estimatedCurrentMonthlyCost'] as num)
          .toDouble(),
      estimatedSavingsIfFollowed: EstimatedSavings.fromJson(
        json['estimatedSavingsIfFollowed'] as Map<String, dynamic>,
      ),
      efficiencyScore: (json['efficiencyScore'] as num).toDouble(),
      keyActions: (json['keyActions'] as List<dynamic>)
          .map((e) => KeyAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      slabAlert: SlabAlert.fromJson(json['slabAlert'] as Map<String, dynamic>),
      quickWins: (json['quickWins'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      monthlyTip: json['monthlyTip'] as String,
    );

Map<String, dynamic> _$EfficiencyPlanModelToJson(
  _EfficiencyPlanModel instance,
) => <String, dynamic>{
  'summary': instance.summary,
  'estimatedCurrentMonthlyCost': instance.estimatedCurrentMonthlyCost,
  'estimatedSavingsIfFollowed': instance.estimatedSavingsIfFollowed.toJson(),
  'efficiencyScore': instance.efficiencyScore,
  'keyActions': instance.keyActions.map((e) => e.toJson()).toList(),
  'slabAlert': instance.slabAlert.toJson(),
  'quickWins': instance.quickWins,
  'monthlyTip': instance.monthlyTip,
};

_EstimatedSavings _$EstimatedSavingsFromJson(Map<String, dynamic> json) =>
    _EstimatedSavings(
      units: (json['units'] as num).toDouble(),
      rupees: (json['rupees'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );

Map<String, dynamic> _$EstimatedSavingsToJson(_EstimatedSavings instance) =>
    <String, dynamic>{
      'units': instance.units,
      'rupees': instance.rupees,
      'percentage': instance.percentage,
    };

_KeyAction _$KeyActionFromJson(Map<String, dynamic> json) => _KeyAction(
  priority: json['priority'] as String,
  appliance: json['appliance'] as String,
  action: json['action'] as String,
  impact: json['impact'] as String,
  estimatedSaving: json['estimatedSaving'] as String,
);

Map<String, dynamic> _$KeyActionToJson(_KeyAction instance) =>
    <String, dynamic>{
      'priority': instance.priority,
      'appliance': instance.appliance,
      'action': instance.action,
      'impact': instance.impact,
      'estimatedSaving': instance.estimatedSaving,
    };

_SlabAlert _$SlabAlertFromJson(Map<String, dynamic> json) => _SlabAlert(
  isInDangerZone: json['isInDangerZone'] as bool,
  currentSlab: json['currentSlab'] as String,
  nextSlabAt: (json['nextSlabAt'] as num?)?.toDouble(),
  unitsToNextSlab: (json['unitsToNextSlab'] as num?)?.toDouble(),
  warning: json['warning'] as String?,
);

Map<String, dynamic> _$SlabAlertToJson(_SlabAlert instance) =>
    <String, dynamic>{
      'isInDangerZone': instance.isInDangerZone,
      'currentSlab': instance.currentSlab,
      'nextSlabAt': instance.nextSlabAt,
      'unitsToNextSlab': instance.unitsToNextSlab,
      'warning': instance.warning,
    };
