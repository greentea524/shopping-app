enum ShippingOption {
  standard('Standard (3-5 days)', 0),
  express('Express (1-2 days)', 9.99),
  overnight('Overnight', 19.99);

  const ShippingOption(this.label, this.fee);

  final String label;
  final double fee;
}
