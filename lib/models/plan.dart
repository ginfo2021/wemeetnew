import 'package:wemeet/utils/converters.dart';

class PlanModel {
  final String name;
  final String code;
  final int amount;
  final String period;
  final String currency;
  final bool currentPlan;
  final LimitModel limit;

  PlanModel({
    this.name,
    this.code,
    this.amount,
    this.period,
    this.currency,
    this.currentPlan,
    this.limit
  });

  factory PlanModel.fromMap(Map map) {
    return PlanModel(
      name: map["name"] ?? "",
      code: map["code"] ?? "",
      amount: ensureInt(map["amount"]),
      period: map["period"] ?? "monthly",
      currency: map["currency"],
      currentPlan: map["currentPlan"] ?? false,
      limit: LimitModel.fromMap(map["limits"] ?? {})
    );
  }
} 

class LimitModel {
  final int dailySwipeLimit;
  final int dailyMessageLimit;
  final bool updateLocation;

  LimitModel({
    this.dailyMessageLimit,
    this.dailySwipeLimit,
    this.updateLocation
  });

  factory LimitModel.fromMap(Map map) {
    return LimitModel(
      dailySwipeLimit: ensureInt(map["dailySwipeLimit"]),
      dailyMessageLimit: ensureInt(map["dailyMessageLimit"]),
      updateLocation: map["updateLocation"] ?? false
    );
  }

  String get swipeText {
    return dailySwipeLimit == -1 ? "Unlimited" : "$dailySwipeLimit per day";
  }

  String get messageText {
    return dailyMessageLimit == -1 ? "Unlimited" : "$dailySwipeLimit per day";
  }

  String get locationText {
    return updateLocation ? "Supported" : "1 per day";
  }
}

/**
 {name: FREE, code: DEFAULT_FREE_PLAN, amount: null, period: null, currency: null, currentPlan: false, limits: {dailySwipeLimit: 1, dailyMessageLimit: 1, updateLocation: false}}
 */