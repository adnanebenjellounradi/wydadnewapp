import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @firstNameLabel.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstNameLabel;

  /// No description provided for @firstNameRequired.
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get firstNameRequired;

  /// No description provided for @firstNameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'First name must contain only letters'**
  String get firstNameLettersOnly;

  /// No description provided for @firstNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'First name must be at least 2 characters'**
  String get firstNameMinLength;

  /// No description provided for @lastNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastNameLabel;

  /// No description provided for @lastNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get lastNameRequired;

  /// No description provided for @lastNameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Last name must contain only letters'**
  String get lastNameLettersOnly;

  /// No description provided for @lastNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Last name must be at least 2 characters'**
  String get lastNameMinLength;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Phone number must start with 6 or 7 and contain 9 digits'**
  String get phoneInvalid;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'6 12 34 56 78'**
  String get phoneHint;

  /// No description provided for @cinLabel.
  ///
  /// In en, this message translates to:
  /// **'ID Card Number'**
  String get cinLabel;

  /// No description provided for @cinMinLength.
  ///
  /// In en, this message translates to:
  /// **'Minimum 5 characters'**
  String get cinMinLength;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Current password is required to change password'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPasswordLabel;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// No description provided for @passwordRequirements.
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one lowercase letter, one uppercase letter, and one number'**
  String get passwordRequirements;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @errorLoadingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error loading profile'**
  String get errorLoadingProfile;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccess;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get updateProfileFailed;

  /// No description provided for @errorUpdatingProfile.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile'**
  String get errorUpdatingProfile;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed. Contact support for any email address modification.'**
  String get emailCannotBeChanged;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'عربي'**
  String get arabic;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @enterYour.
  ///
  /// In en, this message translates to:
  /// **'Enter your {label}'**
  String enterYour(Object label);

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @allSizes.
  ///
  /// In en, this message translates to:
  /// **'All Sizes'**
  String get allSizes;

  /// No description provided for @seeMyOrders.
  ///
  /// In en, this message translates to:
  /// **'See my orders'**
  String get seeMyOrders;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get outOfStock;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to cart'**
  String get addToCart;

  /// No description provided for @viewCart.
  ///
  /// In en, this message translates to:
  /// **'View cart'**
  String get viewCart;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get noProductsFound;

  /// No description provided for @productAddedToCart.
  ///
  /// In en, this message translates to:
  /// **'Product added to cart'**
  String get productAddedToCart;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @verifyItemsBeforeContinuing.
  ///
  /// In en, this message translates to:
  /// **'Verify selected items before continuing:'**
  String get verifyItemsBeforeContinuing;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @size.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get size;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @productsTotal.
  ///
  /// In en, this message translates to:
  /// **'Products total'**
  String get productsTotal;

  /// No description provided for @modify.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modify;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery information'**
  String get deliveryInformation;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your full name'**
  String get fullNameHint;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get fullAddress;

  /// No description provided for @addressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, City, Postal code...'**
  String get addressHint;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery type'**
  String get deliveryType;

  /// No description provided for @casablanca.
  ///
  /// In en, this message translates to:
  /// **'Casablanca'**
  String get casablanca;

  /// No description provided for @otherCities.
  ///
  /// In en, this message translates to:
  /// **'Other cities'**
  String get otherCities;

  /// No description provided for @productsSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Products subtotal'**
  String get productsSubtotal;

  /// No description provided for @deliveryFee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get deliveryFee;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @finalOrderSummary.
  ///
  /// In en, this message translates to:
  /// **'Final order summary'**
  String get finalOrderSummary;

  /// No description provided for @orderedItems.
  ///
  /// In en, this message translates to:
  /// **'Ordered items'**
  String get orderedItems;

  /// No description provided for @verifyOrderInfo.
  ///
  /// In en, this message translates to:
  /// **'Please verify all information before confirming your order.'**
  String get verifyOrderInfo;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed!'**
  String get orderConfirmed;

  /// No description provided for @orderSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your order has been placed successfully. You will receive a call to confirm delivery.'**
  String get orderSuccessMessage;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @unavailableProducts.
  ///
  /// In en, this message translates to:
  /// **'Unavailable products'**
  String get unavailableProducts;

  /// No description provided for @loginRequired.
  ///
  /// In en, this message translates to:
  /// **'Login required'**
  String get loginRequired;

  /// No description provided for @loginToAccess.
  ///
  /// In en, this message translates to:
  /// **'Log in to access this feature.'**
  String get loginToAccess;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @noAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignUp;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @availableSizes.
  ///
  /// In en, this message translates to:
  /// **'Available sizes'**
  String get availableSizes;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name *'**
  String get fullNameRequired;

  /// No description provided for @fullNameLettersOnly.
  ///
  /// In en, this message translates to:
  /// **'Full name must contain only letters'**
  String get fullNameLettersOnly;

  /// No description provided for @fullNameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Full name must be at least 2 characters'**
  String get fullNameMinLength;

  /// No description provided for @addressRequired.
  ///
  /// In en, this message translates to:
  /// **'Delivery address is required'**
  String get addressRequired;

  /// No description provided for @addressMinLength.
  ///
  /// In en, this message translates to:
  /// **'Address must be more detailed (at least 10 characters)'**
  String get addressMinLength;

  /// No description provided for @errorLoadingProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading product details'**
  String get errorLoadingProductDetails;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm deletion'**
  String get confirmDelete;

  /// No description provided for @confirmRemoveProduct.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to remove this product from the cart?'**
  String get confirmRemoveProduct;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @productImage.
  ///
  /// In en, this message translates to:
  /// **'Product image'**
  String get productImage;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @fees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get fees;

  /// No description provided for @delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get delivery;

  /// No description provided for @selectSize.
  ///
  /// In en, this message translates to:
  /// **'Select size'**
  String get selectSize;

  /// No description provided for @selectQuantity.
  ///
  /// In en, this message translates to:
  /// **'Select quantity'**
  String get selectQuantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumber;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order date'**
  String get orderDate;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order status'**
  String get orderStatus;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// No description provided for @paymentStatus.
  ///
  /// In en, this message translates to:
  /// **'Payment status'**
  String get paymentStatus;

  /// No description provided for @trackOrder.
  ///
  /// In en, this message translates to:
  /// **'Track order'**
  String get trackOrder;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support if you think this is an error.'**
  String get contactSupport;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get termsAndConditions;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us'**
  String get contactUs;

  /// No description provided for @faq.
  ///
  /// In en, this message translates to:
  /// **'FAQ'**
  String get faq;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate app'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share app'**
  String get shareApp;

  /// No description provided for @followUs.
  ///
  /// In en, this message translates to:
  /// **'Follow us'**
  String get followUs;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get confirmDeleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning: Deleting your account will permanently lose all your data.'**
  String get deleteAccountWarning;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted successfully'**
  String get accountDeletedSuccess;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed'**
  String get accountDeletionFailed;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired, please login again'**
  String get sessionExpired;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error, please check your internet connection'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @unauthorized.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized, please login'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to access this resource'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found'**
  String get notFound;

  /// No description provided for @validationError.
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload image'**
  String get uploadImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @cameraPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Camera permission required'**
  String get cameraPermissionRequired;

  /// No description provided for @galleryPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Gallery permission required'**
  String get galleryPermissionRequired;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @events.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get events;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @shopUnderMaintenance.
  ///
  /// In en, this message translates to:
  /// **'The shop is currently under maintenance.'**
  String get shopUnderMaintenance;

  /// No description provided for @upcoming.
  ///
  /// In en, this message translates to:
  /// **'Coming'**
  String get upcoming;

  /// No description provided for @past.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noEventsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No events available!'**
  String get noEventsAvailable;

  /// No description provided for @closedOn.
  ///
  /// In en, this message translates to:
  /// **'Closed on'**
  String get closedOn;

  /// No description provided for @startsOn.
  ///
  /// In en, this message translates to:
  /// **'Starts on'**
  String get startsOn;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// No description provided for @vote.
  ///
  /// In en, this message translates to:
  /// **'Vote'**
  String get vote;

  /// No description provided for @myTickets.
  ///
  /// In en, this message translates to:
  /// **'My Tickets'**
  String get myTickets;

  /// No description provided for @ticket.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticket;

  /// No description provided for @maxPerOrder.
  ///
  /// In en, this message translates to:
  /// **'Max per order:'**
  String get maxPerOrder;

  /// No description provided for @buyTickets.
  ///
  /// In en, this message translates to:
  /// **'Buy Tickets'**
  String get buyTickets;

  /// No description provided for @eventNotFound.
  ///
  /// In en, this message translates to:
  /// **'Event not found!'**
  String get eventNotFound;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @eventClosed.
  ///
  /// In en, this message translates to:
  /// **'Event Closed'**
  String get eventClosed;

  /// No description provided for @eventClosedMessage.
  ///
  /// In en, this message translates to:
  /// **'This event is no longer accepting new reservations.'**
  String get eventClosedMessage;

  /// No description provided for @availableTickets.
  ///
  /// In en, this message translates to:
  /// **'Available Tickets'**
  String get availableTickets;

  /// No description provided for @selectNumberOfTickets.
  ///
  /// In en, this message translates to:
  /// **'Select the number of tickets you want'**
  String get selectNumberOfTickets;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to payment'**
  String get proceedToPayment;

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @enterPersonalInfoToFinalizeOrder.
  ///
  /// In en, this message translates to:
  /// **'Please enter your information to finalize your order'**
  String get enterPersonalInfoToFinalizeOrder;

  /// No description provided for @fullNameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid full name (min. 4 letters, at least 2 words, no numbers)'**
  String get fullNameInvalid;

  /// No description provided for @cinRequired.
  ///
  /// In en, this message translates to:
  /// **'National ID Card (CIN) *'**
  String get cinRequired;

  /// No description provided for @cinHint.
  ///
  /// In en, this message translates to:
  /// **'Ex: BK122456'**
  String get cinHint;

  /// No description provided for @cinInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid CIN: must start with 1-2 letters, followed by at least 5 digits'**
  String get cinInvalid;

  /// No description provided for @orderNumberMissing.
  ///
  /// In en, this message translates to:
  /// **'Error: missing order number'**
  String get orderNumberMissing;

  /// No description provided for @orderCreationFailed.
  ///
  /// In en, this message translates to:
  /// **'Order creation failed'**
  String get orderCreationFailed;

  /// No description provided for @orderCreationError.
  ///
  /// In en, this message translates to:
  /// **'Error creating order'**
  String get orderCreationError;

  /// No description provided for @connectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get connectionError;

  /// No description provided for @categoryRestriction.
  ///
  /// In en, this message translates to:
  /// **'Category Restriction'**
  String get categoryRestriction;

  /// No description provided for @categoryRestrictionMessage.
  ///
  /// In en, this message translates to:
  /// **'You can only purchase one ticket category. Please reset the quantity of your previous ticket to 0 to add this one.'**
  String get categoryRestrictionMessage;

  /// No description provided for @event.
  ///
  /// In en, this message translates to:
  /// **'event'**
  String get event;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailToReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a reset code.'**
  String get enterEmailToReceiveCode;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @enterCodeAndNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter the code received by email and your new password.'**
  String get enterCodeAndNewPassword;

  /// No description provided for @resetCode.
  ///
  /// In en, this message translates to:
  /// **'Reset Code'**
  String get resetCode;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change email'**
  String get changeEmail;

  /// No description provided for @resetCodeInfo.
  ///
  /// In en, this message translates to:
  /// **'The reset code is valid for 1 hour. Make sure to check your inbox and spam folder.'**
  String get resetCodeInfo;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @resetCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Reset code is required'**
  String get resetCodeRequired;

  /// No description provided for @resetCodeLength.
  ///
  /// In en, this message translates to:
  /// **'The code must contain 6 digits'**
  String get resetCodeLength;

  /// No description provided for @resetCodeDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'The code must contain only digits'**
  String get resetCodeDigitsOnly;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password confirmation is required'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @codeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Code sent to your email'**
  String get codeSentToEmail;

  /// No description provided for @errorSendingCode.
  ///
  /// In en, this message translates to:
  /// **'Error sending code'**
  String get errorSendingCode;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @errorResettingPassword.
  ///
  /// In en, this message translates to:
  /// **'Error resetting password'**
  String get errorResettingPassword;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @order.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get order;

  /// No description provided for @tickets.
  ///
  /// In en, this message translates to:
  /// **'Tickets'**
  String get tickets;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @noOrdersForThisEvent.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t placed any orders for this event yet.'**
  String get noOrdersForThisEvent;

  /// No description provided for @ordersFor.
  ///
  /// In en, this message translates to:
  /// **'Orders for'**
  String get ordersFor;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @endedOn.
  ///
  /// In en, this message translates to:
  /// **'Ended on'**
  String get endedOn;

  /// No description provided for @ticketPlural.
  ///
  /// In en, this message translates to:
  /// **'ticket(s)'**
  String get ticketPlural;

  /// No description provided for @forYou.
  ///
  /// In en, this message translates to:
  /// **'For you'**
  String get forYou;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @transferPending.
  ///
  /// In en, this message translates to:
  /// **'Transfer pending'**
  String get transferPending;

  /// No description provided for @transferAccepted.
  ///
  /// In en, this message translates to:
  /// **'Transfer accepted'**
  String get transferAccepted;

  /// No description provided for @transferRejected.
  ///
  /// In en, this message translates to:
  /// **'Transfer rejected'**
  String get transferRejected;

  /// No description provided for @transferred.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get transferred;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last name'**
  String get lastName;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get registerButton;

  /// No description provided for @registrationError.
  ///
  /// In en, this message translates to:
  /// **'Registration Error'**
  String get registrationError;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get registrationSuccess;

  /// No description provided for @verifyEmailMessage.
  ///
  /// In en, this message translates to:
  /// **'Please check your email to activate your account before logging in.'**
  String get verifyEmailMessage;

  /// No description provided for @registrationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred during registration.'**
  String get registrationErrorGeneric;

  /// No description provided for @internetConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Internet connection problem. Please check your connection.'**
  String get internetConnectionError;

  /// No description provided for @loginToAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to your account'**
  String get loginToAccount;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get loginButton;

  /// No description provided for @guestAccess.
  ///
  /// In en, this message translates to:
  /// **'ACCESS AS GUEST'**
  String get guestAccess;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login Error'**
  String get loginError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @invalidServerResponse.
  ///
  /// In en, this message translates to:
  /// **'Invalid server response'**
  String get invalidServerResponse;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect credentials'**
  String get incorrectCredentials;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'DETAILS'**
  String get details;

  /// No description provided for @cannotOpenWebsite.
  ///
  /// In en, this message translates to:
  /// **'Unable to open website'**
  String get cannotOpenWebsite;

  /// No description provided for @productNotFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get productNotFound;

  /// No description provided for @failedToLoadProductDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load product details'**
  String get failedToLoadProductDetails;

  /// No description provided for @noDescriptionAvailable.
  ///
  /// In en, this message translates to:
  /// **'No description available'**
  String get noDescriptionAvailable;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @manOfTheMatch.
  ///
  /// In en, this message translates to:
  /// **'MAN OF THE MATCH'**
  String get manOfTheMatch;

  /// No description provided for @voteManOfTheMatch.
  ///
  /// In en, this message translates to:
  /// **'VOTE MAN OF THE MATCH'**
  String get voteManOfTheMatch;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @failedToLoadEventDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load event details'**
  String get failedToLoadEventDetails;

  /// No description provided for @failedToLoadPlayers.
  ///
  /// In en, this message translates to:
  /// **'Failed to load players'**
  String get failedToLoadPlayers;

  /// No description provided for @loginRequiredToVote.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to vote'**
  String get loginRequiredToVote;

  /// No description provided for @failedToSubmitVote.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit vote'**
  String get failedToSubmitVote;

  /// No description provided for @errorSubmittingVote.
  ///
  /// In en, this message translates to:
  /// **'Error submitting vote'**
  String get errorSubmittingVote;

  /// No description provided for @alreadyVotedForEvent.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted a vote for this event'**
  String get alreadyVotedForEvent;

  /// No description provided for @alreadySelectedPlayer.
  ///
  /// In en, this message translates to:
  /// **'You have already selected a player'**
  String get alreadySelectedPlayer;

  /// No description provided for @confirmVote.
  ///
  /// In en, this message translates to:
  /// **'Confirm your vote'**
  String get confirmVote;

  /// No description provided for @voteFor.
  ///
  /// In en, this message translates to:
  /// **'Do you want to vote for'**
  String get voteFor;

  /// No description provided for @voteConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'By confirming, your vote will be immediately submitted and cannot be modified.'**
  String get voteConfirmationMessage;

  /// No description provided for @confirmAndSubmit.
  ///
  /// In en, this message translates to:
  /// **'Confirm and Submit'**
  String get confirmAndSubmit;

  /// No description provided for @addCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get addCommentOptional;

  /// No description provided for @yourComment.
  ///
  /// In en, this message translates to:
  /// **'Your comment...'**
  String get yourComment;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @votedForPlayer.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get votedForPlayer;

  /// No description provided for @voted.
  ///
  /// In en, this message translates to:
  /// **'Voted'**
  String get voted;

  /// No description provided for @thankYouForVote.
  ///
  /// In en, this message translates to:
  /// **'Thank you for voting!'**
  String get thankYouForVote;

  /// No description provided for @youVotedFor.
  ///
  /// In en, this message translates to:
  /// **'You voted for'**
  String get youVotedFor;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @unknownPlayer.
  ///
  /// In en, this message translates to:
  /// **'Unknown player'**
  String get unknownPlayer;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get yearsOld;

  /// No description provided for @votes.
  ///
  /// In en, this message translates to:
  /// **'votes'**
  String get votes;

  /// No description provided for @loginToVote.
  ///
  /// In en, this message translates to:
  /// **'Log in to vote'**
  String get loginToVote;

  /// No description provided for @eventFinishedVotesClosed.
  ///
  /// In en, this message translates to:
  /// **'Event finished - Voting is closed'**
  String get eventFinishedVotesClosed;

  /// No description provided for @alreadyVotedForEventMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted a vote for this event. Thank you for your participation!'**
  String get alreadyVotedForEventMessage;

  /// No description provided for @onlyOneVoteAllowed.
  ///
  /// In en, this message translates to:
  /// **'You can only vote for one player.'**
  String get onlyOneVoteAllowed;

  /// No description provided for @substitutes.
  ///
  /// In en, this message translates to:
  /// **'Substitutes'**
  String get substitutes;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'No.'**
  String get number;

  /// No description provided for @youVoted.
  ///
  /// In en, this message translates to:
  /// **'You voted'**
  String get youVoted;

  /// No description provided for @seeSubstitutes.
  ///
  /// In en, this message translates to:
  /// **'SEE SUBSTITUTES'**
  String get seeSubstitutes;

  /// No description provided for @alreadyVotedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already submitted a vote for this event. Thank you for your participation!'**
  String get alreadyVotedMessage;

  /// No description provided for @loginToVoteMessage.
  ///
  /// In en, this message translates to:
  /// **'Log in to vote for your favorite player'**
  String get loginToVoteMessage;

  /// No description provided for @manOfTheMatchUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Man of the match unavailable'**
  String get manOfTheMatchUnavailable;

  /// No description provided for @manOfTheMatchUnavailableMessage.
  ///
  /// In en, this message translates to:
  /// **'Data is not available for this event'**
  String get manOfTheMatchUnavailableMessage;

  /// No description provided for @infoTapPlayer.
  ///
  /// In en, this message translates to:
  /// **'Tap on a player to see their details'**
  String get infoTapPlayer;

  /// No description provided for @infoVoteFavorite.
  ///
  /// In en, this message translates to:
  /// **'Vote for your favorite player (1 vote only)'**
  String get infoVoteFavorite;

  /// No description provided for @infoAddComment.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get infoAddComment;

  /// No description provided for @infoTopThree.
  ///
  /// In en, this message translates to:
  /// **'The top 3 players are on the podium'**
  String get infoTopThree;

  /// No description provided for @infoSingleVote.
  ///
  /// In en, this message translates to:
  /// **'Single and definitive vote'**
  String get infoSingleVote;

  /// No description provided for @infoVotingOpen.
  ///
  /// In en, this message translates to:
  /// **'Voting is open until the end of the match'**
  String get infoVotingOpen;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @ticketPendingAcceptance.
  ///
  /// In en, this message translates to:
  /// **'Ticket pending acceptance'**
  String get ticketPendingAcceptance;

  /// No description provided for @noTicketsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No tickets available'**
  String get noTicketsAvailable;

  /// No description provided for @transferInProgress.
  ///
  /// In en, this message translates to:
  /// **'Transfer in progress...'**
  String get transferInProgress;

  /// No description provided for @transferredSuccessfullyTo.
  ///
  /// In en, this message translates to:
  /// **'transferred successfully to'**
  String get transferredSuccessfullyTo;

  /// No description provided for @transferError.
  ///
  /// In en, this message translates to:
  /// **'Transfer error'**
  String get transferError;

  /// No description provided for @enterRecipientEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter the email address of the person you want to transfer your tickets to'**
  String get enterRecipientEmail;

  /// No description provided for @emailExample.
  ///
  /// In en, this message translates to:
  /// **'example@mail.com'**
  String get emailExample;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email.'**
  String get enterValidEmail;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @userNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find the user'**
  String get userNotFoundMessage;

  /// No description provided for @inviteQuestion.
  ///
  /// In en, this message translates to:
  /// **'Would you like to invite them?'**
  String get inviteQuestion;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// No description provided for @invitationSentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Invitation sent successfully'**
  String get invitationSentSuccess;

  /// No description provided for @invitationError.
  ///
  /// In en, this message translates to:
  /// **'Invitation error'**
  String get invitationError;

  /// No description provided for @confirmationSend.
  ///
  /// In en, this message translates to:
  /// **'Confirmation of sending'**
  String get confirmationSend;

  /// No description provided for @aboutToSend.
  ///
  /// In en, this message translates to:
  /// **'You are about to send'**
  String get aboutToSend;

  /// No description provided for @irreversibleAction.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible.'**
  String get irreversibleAction;

  /// No description provided for @continueQuestion.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get continueQuestion;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @transferTickets.
  ///
  /// In en, this message translates to:
  /// **'TRANSFER TICKETS'**
  String get transferTickets;

  /// No description provided for @eventEnded.
  ///
  /// In en, this message translates to:
  /// **'Event Ended'**
  String get eventEnded;

  /// No description provided for @qrCodeNotAuthorized.
  ///
  /// In en, this message translates to:
  /// **'QR code access is not authorized for this ticket category'**
  String get qrCodeNotAuthorized;

  /// No description provided for @ticketAlreadyUsed.
  ///
  /// In en, this message translates to:
  /// **'This ticket has already been used'**
  String get ticketAlreadyUsed;

  /// No description provided for @ticketAlreadyTransferred.
  ///
  /// In en, this message translates to:
  /// **'This ticket has already been transferred'**
  String get ticketAlreadyTransferred;

  /// No description provided for @usePhysicalTicket.
  ///
  /// In en, this message translates to:
  /// **'Please use your physical ticket'**
  String get usePhysicalTicket;

  /// No description provided for @qrCodeWillAppearBeforeMatch.
  ///
  /// In en, this message translates to:
  /// **'Your ticket QR code will appear before the match'**
  String get qrCodeWillAppearBeforeMatch;

  /// No description provided for @qrCodeNotAvailableForCategory.
  ///
  /// In en, this message translates to:
  /// **'QR code is not available for this ticket category'**
  String get qrCodeNotAvailableForCategory;

  /// No description provided for @receivedTransferPending.
  ///
  /// In en, this message translates to:
  /// **'You have received a ticket transfer. Please accept or decline.'**
  String get receivedTransferPending;

  /// No description provided for @ticketNotTransferable.
  ///
  /// In en, this message translates to:
  /// **'Non-transferable ticket'**
  String get ticketNotTransferable;

  /// No description provided for @ticketStatus.
  ///
  /// In en, this message translates to:
  /// **'Ticket status'**
  String get ticketStatus;

  /// No description provided for @statusNotPrinted.
  ///
  /// In en, this message translates to:
  /// **'Not printed'**
  String get statusNotPrinted;

  /// No description provided for @statusPrinted.
  ///
  /// In en, this message translates to:
  /// **'Printed'**
  String get statusPrinted;

  /// No description provided for @statusTransferred.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get statusTransferred;

  /// No description provided for @statusUsed.
  ///
  /// In en, this message translates to:
  /// **'Already used'**
  String get statusUsed;

  /// No description provided for @statusUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get statusUnknown;

  /// No description provided for @eventStartsIn.
  ///
  /// In en, this message translates to:
  /// **'Event starts in:'**
  String get eventStartsIn;

  /// No description provided for @eventOngoing.
  ///
  /// In en, this message translates to:
  /// **'Event ongoing'**
  String get eventOngoing;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid date'**
  String get invalidDate;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hours;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @sec.
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get sec;

  /// No description provided for @at.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get at;

  /// No description provided for @gate.
  ///
  /// In en, this message translates to:
  /// **'GATE'**
  String get gate;

  /// No description provided for @access.
  ///
  /// In en, this message translates to:
  /// **'ACCESS'**
  String get access;

  /// No description provided for @block.
  ///
  /// In en, this message translates to:
  /// **'BLOCK'**
  String get block;

  /// No description provided for @seat.
  ///
  /// In en, this message translates to:
  /// **'SEAT'**
  String get seat;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @used.
  ///
  /// In en, this message translates to:
  /// **'USED'**
  String get used;

  /// No description provided for @acceptTransfer.
  ///
  /// In en, this message translates to:
  /// **'Accept transfer'**
  String get acceptTransfer;

  /// No description provided for @rejectTransfer.
  ///
  /// In en, this message translates to:
  /// **'Reject transfer'**
  String get rejectTransfer;

  /// No description provided for @transferAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer accepted successfully'**
  String get transferAcceptedSuccess;

  /// No description provided for @acceptTransferError.
  ///
  /// In en, this message translates to:
  /// **'Error during acceptance'**
  String get acceptTransferError;

  /// No description provided for @rejectTransferError.
  ///
  /// In en, this message translates to:
  /// **'Error during rejection'**
  String get rejectTransferError;

  /// No description provided for @noTicketFound.
  ///
  /// In en, this message translates to:
  /// **'No ticket found'**
  String get noTicketFound;

  /// No description provided for @loadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get loadingError;

  /// No description provided for @transferredTicketWillAppearAfterAcceptance.
  ///
  /// In en, this message translates to:
  /// **'The transferred ticket will only appear after the recipient has accepted it'**
  String get transferredTicketWillAppearAfterAcceptance;

  /// No description provided for @acceptingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Accepting transfer...'**
  String get acceptingTransfer;

  /// No description provided for @rejectingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Rejecting transfer...'**
  String get rejectingTransfer;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get accept;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get reject;

  /// No description provided for @transferInformation.
  ///
  /// In en, this message translates to:
  /// **'Transfer information'**
  String get transferInformation;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @numberOfTickets.
  ///
  /// In en, this message translates to:
  /// **'Number of tickets'**
  String get numberOfTickets;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @transferRejectedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer rejected successfully'**
  String get transferRejectedSuccess;

  /// No description provided for @pendingTransferReceived.
  ///
  /// In en, this message translates to:
  /// **'You have received a pending transfer.'**
  String get pendingTransferReceived;

  /// No description provided for @myTransfers.
  ///
  /// In en, this message translates to:
  /// **'My transfers'**
  String get myTransfers;

  /// No description provided for @loadingTransfers.
  ///
  /// In en, this message translates to:
  /// **'Loading your transfers...'**
  String get loadingTransfers;

  /// No description provided for @userNotConnected.
  ///
  /// In en, this message translates to:
  /// **'User not connected. Please reconnect.'**
  String get userNotConnected;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// No description provided for @noTransfersSent.
  ///
  /// In en, this message translates to:
  /// **'No transfers sent'**
  String get noTransfersSent;

  /// No description provided for @noTransfersSentMessage.
  ///
  /// In en, this message translates to:
  /// **'Tickets you have transferred will appear here'**
  String get noTransfersSentMessage;

  /// No description provided for @totalTransfers.
  ///
  /// In en, this message translates to:
  /// **'Total transfers'**
  String get totalTransfers;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @winTickets.
  ///
  /// In en, this message translates to:
  /// **'Win Tickets'**
  String get winTickets;

  /// No description provided for @noQuizAvailableToday.
  ///
  /// In en, this message translates to:
  /// **'No quiz available for today'**
  String get noQuizAvailableToday;

  /// No description provided for @unableToLoadQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load quizzes'**
  String get unableToLoadQuizzes;

  /// No description provided for @alreadyParticipated.
  ///
  /// In en, this message translates to:
  /// **'Already participated'**
  String get alreadyParticipated;

  /// No description provided for @alreadyParticipatedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already participated in this quiz. Participation is counted only once.'**
  String get alreadyParticipatedMessage;

  /// No description provided for @missingInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing information'**
  String get missingInformation;

  /// No description provided for @loginToSaveScore.
  ///
  /// In en, this message translates to:
  /// **'Please log in so your score can be saved.'**
  String get loginToSaveScore;

  /// No description provided for @yourScoreOf.
  ///
  /// In en, this message translates to:
  /// **'Your score of'**
  String get yourScoreOf;

  /// No description provided for @hasBeenSaved.
  ///
  /// In en, this message translates to:
  /// **'has been saved!'**
  String get hasBeenSaved;

  /// No description provided for @scoreNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your score could not be saved. Please try again.'**
  String get scoreNotSaved;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @expert.
  ///
  /// In en, this message translates to:
  /// **'🏆 Expert!'**
  String get expert;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'🌟 Very good!'**
  String get veryGood;

  /// No description provided for @notBad.
  ///
  /// In en, this message translates to:
  /// **'👍 Not bad!'**
  String get notBad;

  /// No description provided for @studyMore.
  ///
  /// In en, this message translates to:
  /// **'📚 Study a bit more'**
  String get studyMore;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'💪 Keep going!'**
  String get keepGoing;

  /// No description provided for @winnersList.
  ///
  /// In en, this message translates to:
  /// **'Rewarded participants'**
  String get winnersList;

  /// No description provided for @youParticipatedInQuiz.
  ///
  /// In en, this message translates to:
  /// **'You participated in this quiz'**
  String get youParticipatedInQuiz;

  /// No description provided for @ticketsWillBeTransferred.
  ///
  /// In en, this message translates to:
  /// **'We will automatically transfer tickets to rewarded participants'**
  String get ticketsWillBeTransferred;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @secondsPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'20 sec per question'**
  String get secondsPerQuestion;

  /// No description provided for @questionsToTestYourKnowledge.
  ///
  /// In en, this message translates to:
  /// **'questions to test your knowledge'**
  String get questionsToTestYourKnowledge;

  /// No description provided for @sponsor.
  ///
  /// In en, this message translates to:
  /// **'Sponsor'**
  String get sponsor;

  /// No description provided for @thisQuizIsSponsoredBy.
  ///
  /// In en, this message translates to:
  /// **'This quiz is sponsored by'**
  String get thisQuizIsSponsoredBy;

  /// No description provided for @youHaveAlreadyParticipated.
  ///
  /// In en, this message translates to:
  /// **'You have already participated'**
  String get youHaveAlreadyParticipated;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'START THE QUIZ'**
  String get startQuiz;

  /// No description provided for @first.
  ///
  /// In en, this message translates to:
  /// **'1st'**
  String get first;

  /// No description provided for @second.
  ///
  /// In en, this message translates to:
  /// **'2nd'**
  String get second;

  /// No description provided for @third.
  ///
  /// In en, this message translates to:
  /// **'3rd'**
  String get third;

  /// No description provided for @fourth.
  ///
  /// In en, this message translates to:
  /// **'4th'**
  String get fourth;

  /// No description provided for @fifth.
  ///
  /// In en, this message translates to:
  /// **'5th'**
  String get fifth;

  /// No description provided for @th.
  ///
  /// In en, this message translates to:
  /// **'th'**
  String get th;

  /// No description provided for @place.
  ///
  /// In en, this message translates to:
  /// **'place'**
  String get place;

  /// No description provided for @correctAnswer.
  ///
  /// In en, this message translates to:
  /// **'Correct answer!'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong answer...'**
  String get wrongAnswer;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'RESULTS'**
  String get results;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get errorLoadingOrders;

  /// No description provided for @failedToLoadOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed to load order details'**
  String get failedToLoadOrderDetails;

  /// No description provided for @orderDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order deleted successfully'**
  String get orderDeletedSuccess;

  /// No description provided for @failedToDeleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete order'**
  String get failedToDeleteOrder;

  /// No description provided for @errorDeletingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error deleting order'**
  String get errorDeletingOrder;

  /// No description provided for @statusNotProcessed.
  ///
  /// In en, this message translates to:
  /// **'Not processed'**
  String get statusNotProcessed;

  /// No description provided for @statusProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get statusProcessing;

  /// No description provided for @statusProcessed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get statusProcessed;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @statusNotPaid.
  ///
  /// In en, this message translates to:
  /// **'Not paid'**
  String get statusNotPaid;

  /// No description provided for @statusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get statusPaid;

  /// No description provided for @errorLoadingOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading order details'**
  String get errorLoadingOrderDetails;

  /// No description provided for @ordersWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your orders will appear here'**
  String get ordersWillAppearHere;

  /// No description provided for @goToStore.
  ///
  /// In en, this message translates to:
  /// **'Go to store'**
  String get goToStore;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order details'**
  String get orderDetails;

  /// No description provided for @createdOn.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get createdOn;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on'**
  String get paidOn;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @unknownProduct.
  ///
  /// In en, this message translates to:
  /// **'Unknown product'**
  String get unknownProduct;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get unit;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay now'**
  String get payNow;

  /// No description provided for @whatWouldYouLikeToDo.
  ///
  /// In en, this message translates to:
  /// **'What would you like to do?'**
  String get whatWouldYouLikeToDo;

  /// No description provided for @chooseAnOptionBelow.
  ///
  /// In en, this message translates to:
  /// **'Choose an option below'**
  String get chooseAnOptionBelow;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature will be available soon.'**
  String get featureComingSoon;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @quiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get quiz;

  /// No description provided for @loginToAccessQuiz.
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to access the quiz.'**
  String get loginToAccessQuiz;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @paymentSuccess.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentSuccess;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get paymentType;

  /// No description provided for @viewMyOrders.
  ///
  /// In en, this message translates to:
  /// **'View my orders'**
  String get viewMyOrders;

  /// No description provided for @continueShoppingMessage.
  ///
  /// In en, this message translates to:
  /// **'Continue your experience and visit the official WAC store'**
  String get continueShoppingMessage;

  /// No description provided for @cmiPayment.
  ///
  /// In en, this message translates to:
  /// **'CMI Secure Payment'**
  String get cmiPayment;

  /// No description provided for @connectingToPaymentGateway.
  ///
  /// In en, this message translates to:
  /// **'Connecting to payment gateway...'**
  String get connectingToPaymentGateway;

  /// No description provided for @paymentAcceptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been successfully accepted.'**
  String get paymentAcceptedMessage;

  /// No description provided for @visitStore.
  ///
  /// In en, this message translates to:
  /// **'Visit the Store'**
  String get visitStore;

  /// No description provided for @browserInitError.
  ///
  /// In en, this message translates to:
  /// **'Browser initialization error'**
  String get browserInitError;

  /// No description provided for @browserNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Browser not initialized'**
  String get browserNotInitialized;

  /// No description provided for @unexpectedCmiResponse.
  ///
  /// In en, this message translates to:
  /// **'Unexpected CMI response'**
  String get unexpectedCmiResponse;

  /// No description provided for @paymentLoadError.
  ///
  /// In en, this message translates to:
  /// **'Error loading payment'**
  String get paymentLoadError;

  /// No description provided for @initializingBrowser.
  ///
  /// In en, this message translates to:
  /// **'Initializing browser...'**
  String get initializingBrowser;

  /// No description provided for @paymentConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Payment Confirmed!'**
  String get paymentConfirmed;

  /// No description provided for @paymentProcessedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully'**
  String get paymentProcessedSuccess;

  /// No description provided for @orderNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Order number'**
  String get orderNumberTitle;

  /// No description provided for @orderIdTitle.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderIdTitle;

  /// No description provided for @amountTitle.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountTitle;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment date'**
  String get paymentDate;

  /// No description provided for @orderProcessedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your store order has been processed successfully.'**
  String get orderProcessedSuccess;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// No description provided for @byPmg.
  ///
  /// In en, this message translates to:
  /// **'By PMG'**
  String get byPmg;

  /// No description provided for @ticketAlreadyScanned.
  ///
  /// In en, this message translates to:
  /// **'Ticket already scanned'**
  String get ticketAlreadyScanned;

  /// No description provided for @scannedFromOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'This ticket was scanned from another device. Connect from Your proper Device'**
  String get scannedFromOtherDevice;

  /// No description provided for @scanDate.
  ///
  /// In en, this message translates to:
  /// **'Scan date'**
  String get scanDate;

  /// No description provided for @scanDoor.
  ///
  /// In en, this message translates to:
  /// **'Scan door'**
  String get scanDoor;

  /// No description provided for @scanDevice.
  ///
  /// In en, this message translates to:
  /// **'Device'**
  String get scanDevice;

  /// No description provided for @otherDevice.
  ///
  /// In en, this message translates to:
  /// **'Other device'**
  String get otherDevice;

  /// No description provided for @unknownDoor.
  ///
  /// In en, this message translates to:
  /// **'Unknown door'**
  String get unknownDoor;

  /// No description provided for @shareMyProfile.
  ///
  /// In en, this message translates to:
  /// **'Share my profile'**
  String get shareMyProfile;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get myProfile;

  /// No description provided for @scanToGetContact.
  ///
  /// In en, this message translates to:
  /// **'Scan this code to get my contact information'**
  String get scanToGetContact;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareProfile;

  /// No description provided for @shareProfileMessage.
  ///
  /// In en, this message translates to:
  /// **'Hello, to transfer tickets to me, here is my profile on the Wydad Ticketing app : {email}'**
  String shareProfileMessage(Object email);

  /// No description provided for @whatsappNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed on your device'**
  String get whatsappNotInstalled;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @scanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQRCode;

  /// No description provided for @positionQRCodeInFrame.
  ///
  /// In en, this message translates to:
  /// **'Position the QR code in the frame'**
  String get positionQRCodeInFrame;

  /// No description provided for @invalidEmailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get invalidEmailFormat;

  /// No description provided for @userNotInOrganization.
  ///
  /// In en, this message translates to:
  /// **'This user does not belong to your organization'**
  String get userNotInOrganization;

  /// No description provided for @errorCheckingEmail.
  ///
  /// In en, this message translates to:
  /// **'Error checking email'**
  String get errorCheckingEmail;

  /// No description provided for @individualTicketInfo.
  ///
  /// In en, this message translates to:
  /// **'Ticket is individual. Any person accompanying a child must purchase a ticket for them.'**
  String get individualTicketInfo;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get confirmTransfer;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @confirmTransferButton.
  ///
  /// In en, this message translates to:
  /// **'Yes, Transfer'**
  String get confirmTransferButton;

  /// No description provided for @confirmTransferQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to proceed with this transfer?'**
  String get confirmTransferQuestion;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @day_plural.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get day_plural;

  /// No description provided for @hour.
  ///
  /// In en, this message translates to:
  /// **'hour'**
  String get hour;

  /// No description provided for @hour_plural.
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hour_plural;

  /// No description provided for @minute.
  ///
  /// In en, this message translates to:
  /// **'minute'**
  String get minute;

  /// No description provided for @minute_plural.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minute_plural;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @emailVerifiedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'✅ Email verified successfully'**
  String get emailVerifiedSuccessfully;

  /// No description provided for @selectForTransfer.
  ///
  /// In en, this message translates to:
  /// **'Select for transfer'**
  String get selectForTransfer;

  /// No description provided for @scannedAtBarrier.
  ///
  /// In en, this message translates to:
  /// **'Scanned at barrier'**
  String get scannedAtBarrier;

  /// No description provided for @scannedAtDoor.
  ///
  /// In en, this message translates to:
  /// **'Scanned at door'**
  String get scannedAtDoor;

  /// No description provided for @updateRequired.
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// No description provided for @updateRequiredMessage.
  ///
  /// In en, this message translates to:
  /// **'Please update the app to the latest version to view your tickets.'**
  String get updateRequiredMessage;

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// No description provided for @alreadyConnected.
  ///
  /// In en, this message translates to:
  /// **'You are already connected on another device.'**
  String get alreadyConnected;

  /// No description provided for @alreadyConnectedMessage.
  ///
  /// In en, this message translates to:
  /// **'You are already connected on another device.'**
  String get alreadyConnectedMessage;

  /// No description provided for @disconnectInstructions.
  ///
  /// In en, this message translates to:
  /// **'To reconnect, go to the site Wydad.ticketing.ma, then go to My Profile -> Security -> Log out from all devices.'**
  String get disconnectInstructions;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later'**
  String get checkBackLater;

  /// No description provided for @ongoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get ongoing;

  /// No description provided for @cartTitle.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cartTitle;

  /// No description provided for @sizeGuide.
  ///
  /// In en, this message translates to:
  /// **'Size guide'**
  String get sizeGuide;

  /// No description provided for @deliveryHomeMorocco.
  ///
  /// In en, this message translates to:
  /// **'Home delivery across Morocco'**
  String get deliveryHomeMorocco;

  /// No description provided for @deliveryAndPayment.
  ///
  /// In en, this message translates to:
  /// **'Delivery and payment'**
  String get deliveryAndPayment;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get deliveryAddress;

  /// No description provided for @estimatedDelivery.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get estimatedDelivery;

  /// No description provided for @payWith.
  ///
  /// In en, this message translates to:
  /// **'Pay with'**
  String get payWith;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @bankCard.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get bankCard;

  /// No description provided for @totalInclDelivery.
  ///
  /// In en, this message translates to:
  /// **'Total, delivery included'**
  String get totalInclDelivery;

  /// No description provided for @payOrder.
  ///
  /// In en, this message translates to:
  /// **'Pay order'**
  String get payOrder;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
