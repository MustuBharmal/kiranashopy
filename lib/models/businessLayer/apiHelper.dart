import 'dart:convert';
import 'dart:io';

// import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:user/models/aboutUsModel.dart';
import 'package:user/models/addressModel.dart';
import 'package:user/models/appInfoModel.dart';
import 'package:user/models/appNoticeModel.dart';
import 'package:user/models/appSettingModel.dart';
import 'package:user/models/businessLayer/dioResult.dart';
import 'package:user/models/businessLayer/global.dart' as global;
import 'package:user/models/cancelReasonModel.dart';
import 'package:user/models/cartModel.dart';
import 'package:user/models/categoryFilter.dart';
import 'package:user/models/categoryListModel.dart';
import 'package:user/models/categoryProductModel.dart';
import 'package:user/models/cityModel.dart';
import 'package:user/models/couponsModel.dart';
import 'package:user/models/googleMapModel.dart';
import 'package:user/models/homeScreenDataModel.dart';
import 'package:user/models/mapBoxModel.dart';
import 'package:user/models/mapByModel.dart';
import 'package:user/models/membershipModel.dart';
import 'package:user/models/membershipStatusModel.dart';
import 'package:user/models/message_model.dart';
import 'package:user/models/nearByStoreModel.dart';
import 'package:user/models/notificationModel.dart';
import 'package:user/models/orderModel.dart' as models;
import 'package:user/models/paymentGatewayModel.dart';
import 'package:user/models/productDetailModel.dart';
import 'package:user/models/productFilterModel.dart';
import 'package:user/models/rateModel.dart';
import 'package:user/models/recentSearchModel.dart';
import 'package:user/models/societyModel.dart';
import 'package:user/models/store_model.dart';
import 'package:user/models/subCategoryModel.dart';
import 'package:user/models/termsOfServicesModel.dart';
import 'package:user/models/timeSlotModel.dart';
import 'package:user/models/userModel.dart';
import 'package:user/models/walletModel.dart';
import 'package:user/utils/stream_formatter.dart';

class APIHelper {
  static final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  CollectionReference userChatCollectionRef = FirebaseFirestore.instance.collection("chats");
  CollectionReference storeCollectionRef = FirebaseFirestore.instance.collection("store");

  String? url;

  Future<dynamic> addAddress(Address address) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'type': address.type, 'receiver_name': address.receiverName, 'receiver_phone': address.receiverPhone, 'city_name': address.city, 'society_name': address.society, 'house_no': address.houseNo, 'landmark': address.landmark, 'state': address.state, 'pin': address.pincode, 'lat': address.lat, 'lng': address.lng});

      response = await dio.post('${global.baseUrl}add_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - addAddress(): " + e.toString());
    }
  }

  Future<dynamic> addProductRating(int? varientId, double rating, String description) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'varient_id': varientId,
        'store_id': global.nearStoreModel!.id,
        'rating': rating,
        'description': description,
      });
      response = await dio.post('${global.baseUrl}add_product_rating',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - addProductRating(): " + e.toString());
    }
  }

  Future<dynamic> addRemoveWishList(int? varientId) async {
    try {
      // Add product to wishlist and remove from wishlist same API no need to pass any flag logic is handled from backend
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'varient_id': varientId, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}add_rem_wishlist',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - addRemoveWishList(): " + e.toString());
    }
  }

  Future<dynamic> addToCart({int? qty, int? varientId, int? special}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'qty': qty,
        'store_id': global.nearStoreModel!.id,
        'varient_id': varientId,
        'special': special,
      });

      response = await dio.post('${global.baseUrl}add_to_cart',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - addToCart(): " + e.toString());
    }
  }

  Future<dynamic> addWishListToCart() async {
    try {
      // Add all the  product from wishlist to cart
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}wishlist_to_cart',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - addWishListToCart(): " + e.toString());
    }
  }

  Future<dynamic> appAboutUs() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}appaboutus',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = AboutUs.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - appAboutUs(): " + e.toString());
    }
  }

  Future<dynamic> applyCoupon({String? cartId, String? couponCode}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId, 'coupon_code': couponCode});

      response = await dio.post('${global.baseUrl}apply_coupon',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      print('12');
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - applyCoupon(): " + e.toString());
    }
  }

  Future<dynamic> appTermsOfService() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}appterms',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = TermsOfService.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - appTermsOfService(): " + e.toString());
    }
  }

  Future<dynamic> barcodeScanResult(String code) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'ean_code': code, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}search',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = ProductDetail.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - barcodeScanResult(): " + e.toString());
    }
  }

  Future<dynamic> buyMembership(String buyStatus, String paymentGateway, String? transactionId, int? planId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'buy_status': buyStatus,
        'payment_gateway': paymentGateway,
        'transaction_id': transactionId,
        'plan_id': planId,
      });

      response = await dio.post('${global.baseUrl}buymember',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - buyMembership(): " + e.toString());
    }
  }

  Future<dynamic> calbackRequest(String? storeId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': storeId});
      response = await dio.post('${global.baseUrl}callback_req',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - calbackRequest(): " + e.toString());
    }
  }

  Future<bool> callOnFcmApiSendPushNotifications({List<String?>? userToken, String? title, String? body, String? route, String? imageUrl, String? chatId, String? firstName, String? lastName, String? storeId, String? userId, String? globalUserToken}) async {
    final data = {
      "registration_ids": userToken,
      "notification": {
        "title": '$title',
        "body": '$body',
        "sound": "default",
        "color": "#ff3296fa",
        "vibrate": "300",
        "priority": 'high',
      },
      "android": {
        "priority": 'high',
        "notification": {
          "sound": 'default',
          "color": '#ff3296fa',
          "clickAction": 'FLUTTER_NOTIFICATION_CLICK',
          "notificationType": '52',
        },
      },
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "storeId": '$storeId', "route": '$route', "imageUrl": '$imageUrl', "chatId": '$chatId', "firstName": '$firstName', "lastName": '$lastName', "userId": '$userId', "userToken": globalUserToken}
    };
    final headers = {
      'content-type': 'application/json',
      'Authorization': 'key=${global.appInfo!.userServerKey}' // 'key=YOUR_SERVER_KEY'
    };
    final response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'), body: json.encode(data), encoding: Encoding.getByName('utf-8'), headers: headers);
    if (response.statusCode == 200) {
      // on success do sth
      print('Send');
      return true;
    } else {
      print('Error');
      // on failure do sth
      return false;
    }
  }

  Future<dynamic> changePassword(String? phoneNumber, String password) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phoneNumber, 'user_password': password});
      response = await dio.post('${global.baseUrl}change_password',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - changePassword(): " + e.toString());
    }
  }

  Future<dynamic> checkout({String? cartId, String? paymentStatus, String? paymentMethod, String? wallet, String? paymentId, String? paymentGateway}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId, 'payment_method': paymentMethod, 'payment_status': paymentStatus, 'wallet': wallet, 'payment_id': paymentId, 'payment_gateway': paymentGateway});

      response = await dio.post('${global.baseUrl}checkout',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if ((response.statusCode == 200 && response.data["status"] == '1') || (response.statusCode == 200 && response.data["status"] == '2')) {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - checkout(): " + e.toString());
    }
  }

  Future<EmailExist> checkStoreExist(int? storeId, int? userId) async {
    EmailExist isExist = new EmailExist();
    try {
      dynamic storeData;
      ChatStore? chatStore = new ChatStore();
      storeData = await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: storeId).where('userId', isEqualTo: userId).limit(1).snapshots().transform(StreamFormatter.transformer(ChatStore.fromJson)).first;
      chatStore = storeData.isNotEmpty ? storeData[0] : null;
      if (chatStore != null && chatStore.chatId != null) {
        isExist = EmailExist(id: chatStore.chatId, isEMailExist: true);
      } else {
        storeData = await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: userId.toString()).where('userId', isEqualTo: storeId.toString()).limit(1).snapshots().transform(StreamFormatter.transformer(ChatStore.fromJson)).first;
        chatStore = storeData.isNotEmpty ? storeData[0] : null;
        if (chatStore != null && chatStore.chatId != null) {
          isExist = EmailExist(id: chatStore.chatId, isEMailExist: true);
        } else {
          String chatId = '$userId' + '_' + '$storeId';

          chatStore = ChatStore(chatId: chatId, createdAt: DateTime.now(), storeId: storeId, userId: userId, name: global.currentUser!.name, userProfileImageUrl: global.currentUser!.userImage, userFcmToken: await FirebaseMessaging.instance.getToken());

          //add store
          await storeCollectionRef.add(chatStore.toJson()).catchError((e) {
            print('Create store exception' + e);
          });
          isExist = EmailExist(id: chatId, isEMailExist: false);
        }
      }
    } catch (err) {
      print("Exception - checkStoreExist(): " + err.toString());
    }
    return isExist;
  }

  Future<dynamic> deleteAllNotification() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}delete_all_notification',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - deleteAllNotification(): " + e.toString());
    }
  }

  Future<dynamic> deleteOrder(String? cartId, String? cancelReason) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'cart_id': cartId,
        'reason': cancelReason,
      });

      response = await dio.post('${global.baseUrl}delete_order',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - deleteOrder(): " + e.toString());
    }
  }

  Future<dynamic> delFromCart({int? varientId}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'varient_id': varientId,
      });

      response = await dio.post('${global.baseUrl}del_frm_cart',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = Cart.fromJson(response.data);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - delFromCart(): " + e.toString());
    }
  }

  Future<dynamic> editAddress(Address address) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'address_id': address.addressId, 'user_id': global.currentUser!.id, 'type': address.type, 'receiver_name': address.receiverName, 'receiver_phone': address.receiverPhone, 'city_name': address.city, 'society_name': address.society, 'house_no': address.houseNo, 'landmark': address.landmark, 'state': address.state, 'pin': address.pincode, 'lat': address.lat, 'lng': address.lng});

      response = await dio.post('${global.baseUrl}edit_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - editAddress(): " + e.toString());
    }
  }

  Future<dynamic> firebaseOTPVerification(String? phone, String? status) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'status': status});
      response = await dio.post('${global.baseUrl}verifyOtpPassfirebase',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'].toString() == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - firebaseOTPVerification(): " + e.toString());
    }
  }

  Future<dynamic> forgotPassword(String userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}forget_password',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - forgotPassword(): " + e.toString());
    }
  }

  Future<dynamic> getActiveOrders(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}my_orders?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<models.Order>.from(response.data["data"].map((x) => models.Order.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getOrderHistory(): " + e.toString());
    }
  }

  Future<dynamic> getAddressList() async {
    print(global.currentUser!.id);
    print(global.nearStoreModel!.id);
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}show_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Address>.from(response.data["data"].map((x) => Address.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getAddressList(): " + e.toString());
    }
  }

  Future<dynamic> getAllNotification(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}notificationlist?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<NotificationModel>.from(response.data["data"].map((x) => NotificationModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getAllNotification(): " + e.toString());
    }
  }

  Future<dynamic> getAppInfo(int? userId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': userId});
      response = await dio.post('${global.baseUrl}app_info',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      print(response.data);
      if (response.statusCode == 200) {
        // TODO:
        // recordList = await Isolate.run(() async {
        //   return AppInfo.fromJson(response.data);
        // });

        recordList = AppInfo.fromJson(response.data);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getAppInfo(): " + e.toString());
    }
  }

  Future<dynamic> getAppNotice() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}app_notice',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = AppNotice.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getAppNotice(): " + e.toString());
    }
  }

  Future<dynamic> getAppSetting() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}appsetting',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = AppSetting.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - appSetting(): " + e.toString());
    }
  }

  Future<dynamic> getBannerProductDetail(int? varientId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'varient_id': varientId,
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}banner_var',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = ProductDetail.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getBannerProductDetail(): " + e.toString());
    }
  }

  Future<dynamic> getCancelReason() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}cancelling_reasons',
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<CancelReason>.from(response.data["data"].map((x) => CancelReason.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getCancelReason(): " + e.toString());
    }
  }

  Future<dynamic> getCategoryList(CategoryFilter categoryFilter, int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'byname': categoryFilter.byname,
        'latest': categoryFilter.latest,
      });

      response = await dio.post('${global.baseUrl}catee?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<CategoryList>.from(response.data["data"].map((x) => CategoryList.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getCategoryList(): " + e.toString());
    }
  }

  Future<dynamic> getCategoryProducts(int? catId, int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'cat_id': catId,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}cat_product?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getCategoryProducts(): " + e.toString());
    }
  }

  Stream<List<MessagesModel>>? getChatMessages(String? idUser, String globalId) {
    try {
      return FirebaseFirestore.instance.collection('chats/$idUser/userschat').doc(globalId).collection('messages').orderBy("createdAt", descending: true).snapshots().transform(StreamFormatter.transformer(MessagesModel.fromJson));
    } catch (err) {
      print("Exception - apiHelper.dart - getChatMessages()" + err.toString());
      return null;
    }
  }

  Future<dynamic> getCity() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}city',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<City>.from(response.data["data"].map((x) => City.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getCity(): " + e.toString());
    }
  }

  Future<dynamic> getCompletedOrders(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}completed_orders?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<models.Order>.from(response.data["data"].map((x) => models.Order.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getCompletedOrders(): " + e.toString());
    }
  }

  Future<dynamic> getCoupons({String? cartId}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'cart_id': cartId});
      response = await dio.post('${global.baseUrl}couponlist',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Coupon>.from(response.data["data"].map((x) => Coupon.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getStoreCoupons(): " + e.toString());
    }
  }

  Future<dynamic> getDealProducts(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}dealproduct?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getDealProducts(): " + e.toString());
    }
  }

  dynamic getDioResult<T>(final response, T recordList) {
    try {
      dynamic result;
      result = DioResult.fromJson(response, recordList);
      return result;
    } catch (e) {
      print("Exception - getDioResult():" + e.toString());
    }
  }

  Future<dynamic> getGoogleMapApiKey() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}google_map',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = GoogleMapModel.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getGoogleMapApiKey(): " + e.toString());
    }
  }

  Future<dynamic> getHomeScreenData() async {
    try {
      print('Near by store id: ${global.nearStoreModel?.id}');
      print('Current user id: ${global.currentUser?.id}');
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel?.id,
        'user_id': global.currentUser?.id,
      });
      response = await dio.post('${global.baseUrl}oneapi',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        // TODO:
        // recordList = await Isolate.run(() async {
        //   return HomeScreenData.fromJson(response.data);
        // });
        recordList = HomeScreenData.fromJson(response.data);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getHomeScreenData(): " + e.toString());
    }
  }

  Future<dynamic> getMapBoxApiKey() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}mapbox',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = MapBoxModel.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getMapBoxApiKey(): " + e.toString());
    }
  }

  Future<dynamic> getMapByFlag() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}mapby',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Mapby.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getMapByFlag(): " + e.toString());
    }
  }

  Future<dynamic> getMembershipList() async {
    try {
      Response response;
      var dio = Dio();

      response = await dio.get('${global.baseUrl}membership_plan',
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      print(response.data);
      if (response.statusCode == 200) {
        recordList = List<MembershipModel>.from(response.data["data"].map((x) => MembershipModel.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getMembershipList(): " + e.toString());
    }
  }

  Future<dynamic> getNearbyStore() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'lat': global.lat, 'lng': global.lng});
      response = await dio.post('${global.baseUrl}getneareststore',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      print(response.data);
      if (response.statusCode == 200 && '${response.data['status']}' == '1') {
        recordList = NearStoreModel.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getNearbyStore(): " + e.toString());
    }
  }

  Future<dynamic> getPaymentGateways() async {
    try {
      Response response;
      var dio = Dio();
      response = await dio.get('${global.baseUrl}payment_gateways',
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] != null) {
        recordList = PaymentGateway.fromJson(response.data);
      } else {
        response.data['status'] = '0';
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getPaymentGateways(): " + e.toString());
    }
  }

  Future<dynamic> getProductDetail(int? productId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'product_id': productId, 'store_id': global.nearStoreModel!.id});

      response = await dio.post('${global.baseUrl}product_det',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = ProductDetail.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getProductDetail(): " + e.toString());
    }
  }

  Future<dynamic> getproductSearchResult(String? keyWord, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'keyword': keyWord, 'user_id': global.currentUser!.id, 'byname': productFilter.byname, 'min_price': productFilter.minPrice, 'max_price': productFilter.maxPrice, 'stock': productFilter.stock, 'min_discount': productFilter.minDiscount, 'max_discount': productFilter.maxDiscount, 'min_rating': productFilter.minRating, 'max_rating': productFilter.maxRating});

      response = await dio.post('${global.baseUrl}searchbystore',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getproductSearchResult(): " + e.toString());
    }
  }

  Future<dynamic> getSociety(int? cityId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'city_id': cityId});
      response = await dio.post('${global.baseUrl}society',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Society>.from(response.data["data"].map((x) => Society.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getSociety(): " + e.toString());
    }
  }

  Future<dynamic> getSocietyForAddress() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}societyforaddress',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Society>.from(response.data["data"].map((x) => Society.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getSocietyForAddress(): " + e.toString());
    }
  }

  Future<dynamic> getStoreCoupons() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'store_id': global.nearStoreModel!.id});
      response = await dio.post('${global.baseUrl}storecoupons',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Coupon>.from(response.data["data"].map((x) => Coupon.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getStoreCoupons(): " + e.toString());
    }
  }

  Future<dynamic> getSubCategory(int page, int? catId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'cat_id': catId});

      response = await dio.post('${global.baseUrl}subcatee?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<SubCategory>.from(response.data["data"].map((x) => SubCategory.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getSubCategory(): " + e.toString());
    }
  }

  Future<dynamic> getTagProducts(String? tagName, int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'tag_name': tagName,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}tag_product?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - tagProducts(): " + e.toString());
    }
  }

  Future<dynamic> getTimeSlot(DateTime? selectedDate) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'store_id': global.nearStoreModel!.id, 'selected_date': selectedDate});

      response = await dio
          .post('${global.baseUrl}timeslot',
              data: formData,
              options: Options(
                headers: await global.getApiHeaders(true),
              ))
          .timeout(Duration(seconds: 60));
      dynamic recordList;
      print(response.data);
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<TimeSlot>.from(response.data["data"].map((x) => TimeSlot.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getTimeSlot(): " + e.toString());
    }
  }

  Future<dynamic> getTopSellingProducts(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'user_id': global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });

      response = await dio.post('${global.baseUrl}top_selling?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getTopSellingProducts(): " + e.toString());
    }
  }

  getWalletRechargeHistory(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        "user_id": global.currentUser!.id,
      });
      response = await dio.post('${global.baseUrl}wallet_recharge_history?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Wallet>.from(response.data["data"].map((x) => Wallet.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getWalletRechargeHistory(): " + e.toString());
    }
  }

  getWalletSpentHistory(int page) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        "user_id": global.currentUser!.id,
      });
      response = await dio.post('${global.baseUrl}paid_by_wallet?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Wallet>.from(response.data["data"].map((x) => Wallet.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getWalletSpentHistory(): " + e.toString());
    }
  }

  getWishListProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}show_wishlist?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getWishListProduct(): " + e.toString());
    }
  }

  Future<dynamic> login(String userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}login',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      print(response.data);
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - login(): " + e.toString());
    }
  }

  Future<dynamic> loginWithEmail(String email, String password) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'email': email, 'password': password, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}login_with_email',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data['token'];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - loginWithEmail(): " + e.toString());
    }
  }

  Future<dynamic> makeOrder({DateTime? selectedDate, String? selectedTime}) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'delivery_date': selectedDate, 'time_slot': selectedTime});

      response = await dio.post('${global.baseUrl}make_order',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - makeOrder(): " + e.toString());
    }
  }

  Future<dynamic> makeProductRequest(int? addressId, File? imageFile) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'store_id': global.nearStoreModel!.id,
        'address_id': addressId,
        'orderlist': imageFile != null ? await MultipartFile.fromFile(imageFile.path.toString()) : null,
      });

      response = await dio.post('${global.baseUrl}orderlist',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - makeProductRequest(): " + e.toString());
    }
  }

  Future<dynamic> membershipStatus() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}membership_status',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = MembershipStatus.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - membershipStatus(): " + e.toString());
    }
  }

  Future<dynamic> myProfile() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});
      response = await dio.post('${global.baseUrl}myprofile',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - myProfile(): " + e.toString());
    }
  }

  recentSellingProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}recentselling?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - recentSellingProduct(): " + e.toString());
    }
  }

  Future<dynamic> rechargeWallet(String rechargeStatus, double amount, String? paymentId, String paymentGateway) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'recharge_status': rechargeStatus,
        'amount': amount.toStringAsFixed(2),
        'payment_id': paymentId,
        'payment_gateway': paymentGateway,
      });

      response = await dio.post('${global.baseUrl}recharge_wallet',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if ((response.statusCode == 200 && response.data["status"] == '1')) {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - rechargeWallet(): " + e.toString());
    }
  }

  Future<dynamic> redeemReward() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id});

      response = await dio.post('${global.baseUrl}redeem_rewards',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - redeemReward(): " + e.toString());
    }
  }

  Future<dynamic> removeAddress(int? addressId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'address_id': addressId,
      });

      response = await dio.post('${global.baseUrl}remove_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - removeAddress(): " + e.toString());
    }
  }

  Future<dynamic> reOrder(String? cartId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'cart_id': cartId});

      response = await dio.post('${global.baseUrl}reorder',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - reOrder(): " + e.toString());
    }
  }

  Future<dynamic> resendOTP(String? userPhone) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': userPhone});
      response = await dio.post('${global.baseUrl}resendotp',
          queryParameters: {
            'lang': 'en',
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - resendOTP(): " + e.toString());
    }
  }

  Future<dynamic> selectAddressForCheckout(int? addressId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'address_id': addressId});

      response = await dio.post('${global.baseUrl}select_address',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = response.data;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - selectAddressForCheckout(): " + e.toString());
    }
  }

  Future<dynamic> sendUserFeedback(String feedback) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_id': global.currentUser!.id, 'feedback': feedback});
      response = await dio.post('${global.baseUrl}user_feedback',
          queryParameters: {
            'lang': global.languageCode,
          },
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - calbackRequest(): " + e.toString());
    }
  }

  Future<dynamic> showCart() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio
          .post('${global.baseUrl}show_cart',
              data: formData,
              options: Options(
                headers: await global.getApiHeaders(true),
              ))
          .timeout(Duration(seconds: 60));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = Cart.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - showCart(): " + e.toString());
    }
  }

  Future<dynamic> showRecentSearch() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}recent_search',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<RecentSearch>.from(response.data["data"].map((x) => RecentSearch.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - showRecentSearch(): " + e.toString());
    }
  }

  Future<dynamic> showTrendingSearchProducts() async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
      });

      response = await dio.post('${global.baseUrl}trendsearchproducts',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - showRecentSearch(): " + e.toString());
    }
  }

  Future<dynamic> signUp(CurrentUser user) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'name': user.name,
        'user_email': user.email,
        'user_phone': user.userPhone,
        'password': user.password,
        'user_city': user.userCity,
        'user_area': user.userArea,
        'device_id': global.appDeviceId,
        'user_image': user.userImageFile != null ? await MultipartFile.fromFile(user.userImageFile!.path.toString()) : null,
        'fb_id': user.fbId != null ? user.fbId : null,
        'referral_code': user.referralCode != null ? user.referralCode : null,
        'apple_id': user.appleId != null ? user.appleId : null,
      });

      response = await dio.post('${global.baseUrl}register_details',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - signUp(): " + e.toString());
    }
  }

  Future<dynamic> socialLogin({String? userEmail, String? facebookId, String? type, String? appleId}) async {
    print(userEmail);
    print(facebookId);
    // print(type);
    // print(appleId);
    try {
      Response response;
      var dio = Dio();

      var formData = FormData.fromMap({"user_email": userEmail, "fb_id": facebookId, "type": type, "apple_id": appleId, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}social_login',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      // CurrentUser recordList;
      print(response.data);
      dynamic recordList;
      if (response.statusCode == 200 && response.data['status'] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data['token'];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - socialLogin(): " + e.toString());
    }
  }

  spotLightProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}spotlight?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - spotLightProduct(): " + e.toString());
    }
  }

  Future<dynamic> trackOrder(String? cartId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'cart_id': cartId});

      response = await dio.post('${global.baseUrl}trackorder',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = models.Order.fromJson(response.data["data"]);
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - trackOrder(): " + e.toString());
    }
  }

  Future<dynamic> updateAppSetting(AppSetting appSetting) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_id': global.currentUser!.id,
        'sms': appSetting.sms! ? 1 : 0,
        'email': appSetting.email! ? 1 : 0,
        'app': appSetting.app! ? 1 : 0,
      });

      response = await dio.post('${global.baseUrl}updateappsetting',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data['data'] == '1') {
        recordList = true;
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - updateAppSetting(): " + e.toString());
    }
  }

  Future updateFirebaseUser(CurrentUser? user) async {
    try {
      List<QueryDocumentSnapshot> storeData = (await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: global.nearStoreModel!.id).where('userId', isEqualTo: global.currentUser!.id).get()).docs.toList();
      if (storeData.isNotEmpty) {
        FirebaseFirestore.instance.collection("store").doc(storeData[0].id).update({"name": user!.name, "userProfileImageUrl": user.userImage, "updatedAt": DateTime.now().toUtc()});
      }
    } catch (e) {
      print("Exception - updateFirebaseUser()" + e.toString());
    }
  }

  Future updateFirebaseUserFcmToken(int? userId, String? updatedFcmToken) async {
    try {
      int? storeId = global.nearStoreModel?.id;
      List<QueryDocumentSnapshot> storeData = (await FirebaseFirestore.instance.collectionGroup("store").where('storeId', isEqualTo: storeId).where('userId', isEqualTo: userId).get()).docs.toList();
      if (storeData.isNotEmpty) {
        FirebaseFirestore.instance.collection("store").doc(storeData[0].id).update({"userFcmToken": updatedFcmToken, "updatedAt": DateTime.now().toUtc()});
      }
    } catch (e) {
      print("Exception - updateFirebaseUser()" + e.toString());
    }
  }

  Future updateImageMesageURL(String? chatId, String userId, String? messageId, String url) async {
    try {
      var _myDoc = FirebaseFirestore.instance
          // .collection('chats/$chatId/messages')
          .collection('chats')
          .doc(chatId)
          .collection('userschat')
          .doc(userId)
          .collection('messages')
          .doc(messageId);

      //  FirebaseFirestore.instance.collection('chats/$chatId/messages');
      _myDoc.update({'url': url});
    } catch (err) {
      print('Exception - updateImageMesageURL(): ${err.toString()}');
    }
  }

  Future<dynamic> updateProfile(CurrentUser user) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'user_name': user.name,
        'user_email': global.currentUser!.email,
        'user_phone': global.currentUser!.userPhone,
        'user_city': user.userCity,
        'user_area': user.userArea,
        'device_id': global.appDeviceId,
        'user_image': user.userImageFile != null ? await MultipartFile.fromFile(user.userImageFile!.path.toString()) : null,
        'user_id': global.currentUser!.id,
      });

      response = await dio.post('${global.baseUrl}profile_edit',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      print(response.data);
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - updateProfile(): " + e.toString());
    }
  }

  Future<String?> uploadImageToStorage(XFile image, String? chatId, String userid, MessagesModel anonymous) async {
    try {
      var messageR = await uploadMessage(chatId, userid, anonymous, false, '');
      var fileName = DateTime.now().microsecondsSinceEpoch.toString();
      var refImg = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = refImg.putFile(File(image.path));
      var imageUrl = await (await uploadTask).ref.getDownloadURL();
      await updateImageMesageURL(chatId, global.currentUser!.id.toString(), messageR['user1'], imageUrl);
      await updateImageMesageURL(chatId, userid, messageR['user2'], imageUrl);

      return url;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future uploadMessage(String? idUser, String userId, MessagesModel anonymous, bool isAlreadychat, String imageUrl) async {
    try {
      final String globalId = global.currentUser!.id.toString();
      // if (!isAlreadychat && userChat.chatId != null) {}
      final refMessages = userChatCollectionRef.doc(idUser).collection('userschat').doc(globalId).collection('messages');
      final refMessages1 = userChatCollectionRef.doc(idUser).collection('userschat').doc(userId).collection('messages');
      final newMessage1 = anonymous;
      final newMessage2 = anonymous;

      var messageResult = await refMessages.add(newMessage1.toJson()).catchError((e) {
        print('send mess exception' + e);
      });
      newMessage2.isRead = false;
      var message1Result = await refMessages1.add(newMessage2.toJson()).catchError((e) {
        print('send mess exception' + e);
      });

      return {
        'user1': messageResult.id,
        'user2': message1Result.id,
      };
    } catch (err) {
      print('uploadMessage err $err');
    }
  }

  Future<dynamic> verifyOTP(String? phone, String otp) async {
    try {
      // OTP verification after forgot password
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'otp': otp});
      response = await dio.post('${global.baseUrl}verifyOtpPass',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - verifyOTP(): " + e.toString());
    }
  }

  Future<dynamic> verifyPhone(String? phone, String otp, String? referralCode) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({'user_phone': phone, 'otp': otp, 'referral_code': referralCode, 'device_id': global.appDeviceId});
      response = await dio.post('${global.baseUrl}verify_phone',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200) {
        recordList = CurrentUser.fromJson(response.data['data']);
        recordList.token = response.data["token"];
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - verifyPhone(): " + e.toString());
    }
  }

  Future<dynamic> verifyViaFirebase(String? phone, String? status, String? referralCode) async {
    // try {
    Response response;

    print(await http.post(
      Uri.parse('${global.baseUrl}verify_via_firebase'),
      headers: await global.getApiHeaders(false),
      body: jsonEncode({
        'user_phone': phone ?? "",
        'status': status ?? "",
        'referral_code': referralCode ?? "",
        'device_id': global.appDeviceId ?? "",
      }),
    ).then((value) => value.body));
    return;
    var dio = Dio();
    var formData = FormData.fromMap({'user_phone': phone, 'status': status, 'referral_code': referralCode, 'device_id': global.appDeviceId});
    response = await dio.post('${global.baseUrl}verify_via_firebase',
        data: formData,
        options: Options(
          headers: await global.getApiHeaders(false),
        ));

    print("--------------------------------------------------------------------------------------------------------------------------------------------------------");
    print(response.data);
    print("--------------------------------------------------------------------------------------------------------------------------------------------------------");
    dynamic recordList;
    if (response.statusCode == 200 && response.data["status"].toString() == "1") {
      recordList = CurrentUser.fromJson(response.data["data"]);

      recordList.token = response.data["token"];
    } else {
      recordList = null;
    }
    return getDioResult(response, recordList);
    // } catch (e) {
    //   print("Exception - verifyViaFirebasesadsad(): " + e.toString());
    // }
  }

  whatsnewProduct(int page, ProductFilter productFilter) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        "user_id": global.currentUser!.id,
        'byname': productFilter.byname,
        'min_price': productFilter.minPrice,
        'max_price': productFilter.maxPrice,
        'stock': productFilter.stock,
        'min_discount': productFilter.minDiscount,
        'max_discount': productFilter.maxDiscount,
        'min_rating': productFilter.minRating,
        'max_rating': productFilter.maxRating,
      });
      response = await dio.post('${global.baseUrl}whatsnew?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(false),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Product>.from(response.data["data"].map((x) => Product.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - whatsnewProduct(): " + e.toString());
    }
  }

  Future<dynamic> getProductRating(int page, int? varientId) async {
    try {
      Response response;
      var dio = Dio();
      var formData = FormData.fromMap({
        'store_id': global.nearStoreModel!.id,
        'varient_id': varientId,
      });
      response = await dio.post('${global.baseUrl}get_product_rating?page=$page',
          data: formData,
          options: Options(
            headers: await global.getApiHeaders(true),
          ));
      dynamic recordList;
      if (response.statusCode == 200 && response.data["status"] == '1') {
        recordList = List<Rate>.from(response.data["data"].map((x) => Rate.fromJson(x)));
      } else {
        recordList = null;
      }
      return getDioResult(response, recordList);
    } catch (e) {
      print("Exception - getProductRating(): " + e.toString());
    }
  }
}

class EmailExist {
  String? id;
  bool? isEMailExist;

  EmailExist({this.id, this.isEMailExist});
}
