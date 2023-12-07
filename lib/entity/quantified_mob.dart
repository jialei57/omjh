class QuantifiedMob {
  final String name;
  final int quantity;

  QuantifiedMob(this.name, this.quantity);

  QuantifiedMob.fromJson(Map<String, dynamic> json)
    : name = json['name'],
      quantity = json['quantity'];
}
