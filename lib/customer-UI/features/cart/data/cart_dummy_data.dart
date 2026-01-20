class CartDummyData {
  static Map<String, dynamic> getMockCartResponse() {
    return {
      "success": true,
      "data": {
        "items_count": 2,
        "total": 19.98,
        "items": [
          {
            "id": 101,
            "bookable_id": 1,
            "bookable_type": "App\\Models\\ServicePackage",
            "quantity": 1,
            "price": "10.99",
            "options": {"date": "30/01/2026"},
            "bookable": {
              "name": "Wedding Package #1",
              "provider_name": "Venue Name",
              "description": "Good venue fgfjgkjfg"
            }
          },
          {
            "id": 102,
            "bookable_id": 5,
            "bookable_type": "App\\Models\\Service",
            "quantity": 1,
            "price": "8.99",
            "options": {"date": "30/01/2026"},
            "bookable": {
              "name": "package #2",
              "provider_name": "photographer name",
              "description": "gkhjgkhjkghjkghjgjhkgjhkgjhg"
            }
          }
        ]
      }
    };
  }
}