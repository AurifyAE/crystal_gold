class KConstants {
  static const secretKey = "IfiuH/ko+rh/gekRvY4Va0s+aGYuGJEAOkbJbChhcqo=";
  static const baseUrl = "https://api.aurify.ae/user";
  static const adminId = "67fe1a27a7ef7568048c4cd2";

  static const contactUrl = '$baseUrl/get-profile/$adminId';

  static const headers = {
    'X-Secret-Key': secretKey,
    'Content-Type': 'application/json',
  };
}
  