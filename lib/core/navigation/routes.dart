class Routes {
  static const login = '/login';
  static const passengers = '/passengers';             // list
  static const passengerDetails = '/passenger-details';// details

  static Map<String, String> qDate(DateTime d) => {
    'date':
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}',
  };

  static Map<String, String> qPassenger(DateTime d, String id) =>
      {...qDate(d), 'id': id};
}