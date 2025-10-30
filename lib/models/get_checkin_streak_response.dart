class GetCheckinStreakResponse {
  int? checkDate;
  int? checkinStreak;
  int? numberOfTurn;

  GetCheckinStreakResponse(
      {this.checkDate, this.checkinStreak, this.numberOfTurn});

  GetCheckinStreakResponse.fromJson(Map<String, dynamic> json) {
    checkDate = json['CheckDate'];
    checkinStreak = json['CheckinStreak'];
    numberOfTurn = json['NumberOfTurn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['CheckDate'] = checkDate;
    data['CheckinStreak'] = checkinStreak;
    data['NumberOfTurn'] = numberOfTurn;
    return data;
  }
}
