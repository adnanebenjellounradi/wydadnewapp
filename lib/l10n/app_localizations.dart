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

  /// No description provided for @emailCannotBeChangedShort.
  ///
  /// In en, this message translates to:
  /// **'Email cannot be changed'**
  String get emailCannotBeChangedShort;

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

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

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

  /// No description provided for @storeTitle.
  ///
  /// In en, this message translates to:
  /// **'STORE'**
  String get storeTitle;

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

  /// No description provided for @sizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Size:'**
  String get sizeLabel;

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
  /// **'Try again'**
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
  /// **'No quiz available today'**
  String get noQuizAvailableToday;

  /// No description provided for @unableToLoadQuizzes.
  ///
  /// In en, this message translates to:
  /// **'Unable to load quizzes'**
  String get unableToLoadQuizzes;

  /// No description provided for @alreadyParticipated.
  ///
  /// In en, this message translates to:
  /// **'You have already participated'**
  String get alreadyParticipated;

  /// No description provided for @alreadyParticipatedMessage.
  ///
  /// In en, this message translates to:
  /// **'You have already participated in this quiz.'**
  String get alreadyParticipatedMessage;

  /// No description provided for @missingInformation.
  ///
  /// In en, this message translates to:
  /// **'Missing information'**
  String get missingInformation;

  /// No description provided for @loginToSaveScore.
  ///
  /// In en, this message translates to:
  /// **'Log in to save your score'**
  String get loginToSaveScore;

  /// No description provided for @yourScoreOf.
  ///
  /// In en, this message translates to:
  /// **'Your score is'**
  String get yourScoreOf;

  /// No description provided for @hasBeenSaved.
  ///
  /// In en, this message translates to:
  /// **'has been saved'**
  String get hasBeenSaved;

  /// No description provided for @scoreNotSaved.
  ///
  /// In en, this message translates to:
  /// **'Your score could not be saved'**
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
  /// **'Expert'**
  String get expert;

  /// No description provided for @veryGood.
  ///
  /// In en, this message translates to:
  /// **'Very good'**
  String get veryGood;

  /// No description provided for @notBad.
  ///
  /// In en, this message translates to:
  /// **'Not bad'**
  String get notBad;

  /// No description provided for @studyMore.
  ///
  /// In en, this message translates to:
  /// **'Study more'**
  String get studyMore;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get keepGoing;

  /// No description provided for @winnersList.
  ///
  /// In en, this message translates to:
  /// **'Winners list'**
  String get winnersList;

  /// No description provided for @youParticipatedInQuiz.
  ///
  /// In en, this message translates to:
  /// **'You participated in the quiz'**
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
  /// **'You have already participated in this quiz'**
  String get youHaveAlreadyParticipated;

  /// No description provided for @startQuiz.
  ///
  /// In en, this message translates to:
  /// **'Start quiz'**
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
  /// **'Correct answer'**
  String get correctAnswer;

  /// No description provided for @wrongAnswer.
  ///
  /// In en, this message translates to:
  /// **'Wrong answer'**
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

  /// No description provided for @wydadAc.
  ///
  /// In en, this message translates to:
  /// **'WYDAD AC'**
  String get wydadAc;

  /// No description provided for @officialTicketing.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL TICKETING'**
  String get officialTicketing;

  /// No description provided for @eventsTitle.
  ///
  /// In en, this message translates to:
  /// **'EVENTS'**
  String get eventsTitle;

  /// No description provided for @reserveSeats.
  ///
  /// In en, this message translates to:
  /// **'Book your seats and subscription'**
  String get reserveSeats;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get reserve;

  /// No description provided for @wydadPay.
  ///
  /// In en, this message translates to:
  /// **'WYDAD PAY'**
  String get wydadPay;

  /// No description provided for @walletTagline.
  ///
  /// In en, this message translates to:
  /// **'Top up, transfer, pay'**
  String get walletTagline;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @balanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balanceLabel;

  /// No description provided for @ticketplace.
  ///
  /// In en, this message translates to:
  /// **'TICKETPLACE'**
  String get ticketplace;

  /// No description provided for @ticketplaceSub.
  ///
  /// In en, this message translates to:
  /// **'Resale between fans'**
  String get ticketplaceSub;

  /// No description provided for @storeSub.
  ///
  /// In en, this message translates to:
  /// **'Jerseys and official products'**
  String get storeSub;

  /// No description provided for @newsSub.
  ///
  /// In en, this message translates to:
  /// **'All the club\'s news'**
  String get newsSub;

  /// No description provided for @fanZone.
  ///
  /// In en, this message translates to:
  /// **'FAN ZONE'**
  String get fanZone;

  /// No description provided for @fanZoneSub.
  ///
  /// In en, this message translates to:
  /// **'Quiz, votes, man of the match'**
  String get fanZoneSub;

  /// No description provided for @chooseStore.
  ///
  /// In en, this message translates to:
  /// **'Choose a store'**
  String get chooseStore;

  /// No description provided for @chooseStoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the official Wydad AC store'**
  String get chooseStoreSubtitle;

  /// No description provided for @kappaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Official Kappa store'**
  String get kappaSubtitle;

  /// No description provided for @wacBrand.
  ///
  /// In en, this message translates to:
  /// **'WAC BRAND'**
  String get wacBrand;

  /// No description provided for @wacBrandSubtitle.
  ///
  /// In en, this message translates to:
  /// **'wacofficialbrand.com'**
  String get wacBrandSubtitle;

  /// No description provided for @ticketplaceLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticketplace'**
  String get ticketplaceLabel;

  /// No description provided for @howToTopUpQuestion.
  ///
  /// In en, this message translates to:
  /// **'How would you like to top up your account?'**
  String get howToTopUpQuestion;

  /// No description provided for @currentBalanceFormat.
  ///
  /// In en, this message translates to:
  /// **'Current balance: {balance} MAD'**
  String currentBalanceFormat(String balance);

  /// No description provided for @bankCardMethod.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get bankCardMethod;

  /// No description provided for @bankCardMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top up using your bank card'**
  String get bankCardMethodSubtitle;

  /// No description provided for @bankTransferMethod.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransferMethod;

  /// No description provided for @bankTransferMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top up via bank transfer'**
  String get bankTransferMethodSubtitle;

  /// No description provided for @cashAtAgency.
  ///
  /// In en, this message translates to:
  /// **'Cash at an agency'**
  String get cashAtAgency;

  /// No description provided for @cashAgencyMethodSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top up at an agency'**
  String get cashAgencyMethodSubtitle;

  /// No description provided for @topUpMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Top up my account'**
  String get topUpMyAccount;

  /// No description provided for @bankTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get bankTransferTitle;

  /// No description provided for @bankTransferDescription.
  ///
  /// In en, this message translates to:
  /// **'Make a bank transfer to your Wydad Pay account.'**
  String get bankTransferDescription;

  /// No description provided for @ribCopied.
  ///
  /// In en, this message translates to:
  /// **'Bank details copied'**
  String get ribCopied;

  /// No description provided for @copyRib.
  ///
  /// In en, this message translates to:
  /// **'Copy RIB'**
  String get copyRib;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Sharing feature coming soon'**
  String get shareComingSoon;

  /// No description provided for @addBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Add a bank account'**
  String get addBankAccount;

  /// No description provided for @addBankAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Add a bank account in your name to perform transactions.'**
  String get addBankAccountDescription;

  /// No description provided for @accountName.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountName;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. My bank account'**
  String get accountNameHint;

  /// No description provided for @ribWithLength.
  ///
  /// In en, this message translates to:
  /// **'Bank account number ({length} digits)'**
  String ribWithLength(String length);

  /// No description provided for @ribHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your bank account number'**
  String get ribHint;

  /// No description provided for @associatedPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Associated phone number'**
  String get associatedPhoneNumber;

  /// No description provided for @phoneNumberHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. 0612345678'**
  String get phoneNumberHint;

  /// No description provided for @accountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Account name is required'**
  String get accountNameRequired;

  /// No description provided for @ribMustContain24Digits.
  ///
  /// In en, this message translates to:
  /// **'The bank account number must contain 24 digits'**
  String get ribMustContain24Digits;

  /// No description provided for @phoneNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneNumberRequired;

  /// No description provided for @addFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add account'**
  String get addFailed;

  /// No description provided for @saveBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Save this account'**
  String get saveBankAccount;

  /// No description provided for @deleteAccountConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this account?'**
  String get deleteAccountConfirmationTitle;

  /// No description provided for @deleteAccountConfirmationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account \"{name}\"?'**
  String deleteAccountConfirmationMessage(String name);

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get deleteFailed;

  /// No description provided for @noBankAccount.
  ///
  /// In en, this message translates to:
  /// **'No bank account registered'**
  String get noBankAccount;

  /// No description provided for @noBankAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'Add an account in your name to receive transfers and make withdrawals.'**
  String get noBankAccountDescription;

  /// No description provided for @myBankAccounts.
  ///
  /// In en, this message translates to:
  /// **'My bank accounts'**
  String get myBankAccounts;

  /// No description provided for @defaultAccountName.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get defaultAccountName;

  /// No description provided for @ribMaskedFormat.
  ///
  /// In en, this message translates to:
  /// **'•••• {rib}'**
  String ribMaskedFormat(String rib);

  /// No description provided for @myWalletRib.
  ///
  /// In en, this message translates to:
  /// **'My Wydad Pay bank details'**
  String get myWalletRib;

  /// No description provided for @accountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get accountHolder;

  /// No description provided for @defaultAccountHolder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get defaultAccountHolder;

  /// No description provided for @bank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get bank;

  /// No description provided for @defaultBank.
  ///
  /// In en, this message translates to:
  /// **'Bank'**
  String get defaultBank;

  /// No description provided for @transferInfo1.
  ///
  /// In en, this message translates to:
  /// **'Use these bank details to transfer money to your Wydad Pay wallet.'**
  String get transferInfo1;

  /// No description provided for @transferInfo2.
  ///
  /// In en, this message translates to:
  /// **'Check the bank details before confirming your transfer.'**
  String get transferInfo2;

  /// No description provided for @transferInfo3.
  ///
  /// In en, this message translates to:
  /// **'The time required to receive the transfer depends on your bank.'**
  String get transferInfo3;

  /// No description provided for @walletTransferInvalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get walletTransferInvalidPhone;

  /// No description provided for @walletTransferMinimumAmount.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount is 10 MAD'**
  String get walletTransferMinimumAmount;

  /// No description provided for @walletTransferPinFourDigits.
  ///
  /// In en, this message translates to:
  /// **'The PIN must contain 4 digits'**
  String get walletTransferPinFourDigits;

  /// No description provided for @walletTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Transfer failed. Please try again.'**
  String get walletTransferFailed;

  /// No description provided for @walletTransferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get walletTransferSuccess;

  /// No description provided for @walletTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Money transfer'**
  String get walletTransferTitle;

  /// No description provided for @walletTransferRecipientQuestion.
  ///
  /// In en, this message translates to:
  /// **'Who would you like to send money to?'**
  String get walletTransferRecipientQuestion;

  /// No description provided for @walletTransferRecipientWalletActive.
  ///
  /// In en, this message translates to:
  /// **'The recipient must have an active Wydad Pay account.'**
  String get walletTransferRecipientWalletActive;

  /// No description provided for @walletTransferPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get walletTransferPhoneNumber;

  /// No description provided for @walletTransferContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get walletTransferContinue;

  /// No description provided for @walletTransferAmountToSend.
  ///
  /// In en, this message translates to:
  /// **'Amount to send'**
  String get walletTransferAmountToSend;

  /// No description provided for @walletTransferOptionalMessage.
  ///
  /// In en, this message translates to:
  /// **'Optional message'**
  String get walletTransferOptionalMessage;

  /// No description provided for @walletTransferNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a message'**
  String get walletTransferNoteHint;

  /// No description provided for @walletTransferYouSend.
  ///
  /// In en, this message translates to:
  /// **'You send'**
  String get walletTransferYouSend;

  /// No description provided for @walletTransferBeneficiary.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get walletTransferBeneficiary;

  /// No description provided for @walletTransferMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get walletTransferMessage;

  /// No description provided for @walletTransferEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get walletTransferEnterPin;

  /// No description provided for @walletTransferConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm transfer'**
  String get walletTransferConfirm;

  /// No description provided for @walletTransferCreditSent.
  ///
  /// In en, this message translates to:
  /// **'Your transfer has been sent successfully'**
  String get walletTransferCreditSent;

  /// No description provided for @walletTransferDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get walletTransferDate;

  /// No description provided for @walletTransferPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get walletTransferPhone;

  /// No description provided for @walletTransferReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get walletTransferReference;

  /// No description provided for @walletTransferBackToWallet.
  ///
  /// In en, this message translates to:
  /// **'Back to wallet'**
  String get walletTransferBackToWallet;

  /// No description provided for @walletTransferToRecipient.
  ///
  /// In en, this message translates to:
  /// **'Transfer to {recipient}'**
  String walletTransferToRecipient(String recipient);

  /// No description provided for @walletWithdrawMyWydadPayAccount.
  ///
  /// In en, this message translates to:
  /// **'My Wydad Pay account'**
  String get walletWithdrawMyWydadPayAccount;

  /// No description provided for @walletWithdrawBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get walletWithdrawBankAccount;

  /// No description provided for @walletWithdrawNoBankAccount.
  ///
  /// In en, this message translates to:
  /// **'No bank account registered'**
  String get walletWithdrawNoBankAccount;

  /// No description provided for @walletWithdrawPinFourDigits.
  ///
  /// In en, this message translates to:
  /// **'The PIN must contain 4 digits'**
  String get walletWithdrawPinFourDigits;

  /// No description provided for @walletWithdrawMinimumAmount.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount is 50 MAD'**
  String get walletWithdrawMinimumAmount;

  /// No description provided for @walletWithdrawInsufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get walletWithdrawInsufficientBalance;

  /// No description provided for @walletWithdrawTransferFailed.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer failed. Please try again.'**
  String get walletWithdrawTransferFailed;

  /// No description provided for @walletWithdrawDeleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this bank account?'**
  String get walletWithdrawDeleteAccountTitle;

  /// No description provided for @walletWithdrawDeleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the account \"{name}\"?'**
  String walletWithdrawDeleteAccountMessage(String name);

  /// No description provided for @walletWithdrawCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get walletWithdrawCancel;

  /// No description provided for @walletWithdrawDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get walletWithdrawDelete;

  /// No description provided for @walletWithdrawDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete account'**
  String get walletWithdrawDeleteFailed;

  /// No description provided for @walletWithdrawBankTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw to a bank account'**
  String get walletWithdrawBankTitle;

  /// No description provided for @walletWithdrawDestinationAccount.
  ///
  /// In en, this message translates to:
  /// **'Destination account'**
  String get walletWithdrawDestinationAccount;

  /// No description provided for @walletWithdrawAddAnotherAccount.
  ///
  /// In en, this message translates to:
  /// **'Add another account'**
  String get walletWithdrawAddAnotherAccount;

  /// No description provided for @walletWithdrawAmount.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal amount'**
  String get walletWithdrawAmount;

  /// No description provided for @walletWithdrawBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {amount} MAD'**
  String walletWithdrawBalance(String amount);

  /// No description provided for @walletWithdrawEstimatedReception.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get walletWithdrawEstimatedReception;

  /// No description provided for @walletWithdrawEnterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get walletWithdrawEnterPin;

  /// No description provided for @walletWithdrawButton.
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount} MAD'**
  String walletWithdrawButton(String amount);

  /// No description provided for @walletWithdrawInMyName.
  ///
  /// In en, this message translates to:
  /// **'In my name'**
  String get walletWithdrawInMyName;

  /// No description provided for @walletWithdrawRib.
  ///
  /// In en, this message translates to:
  /// **'Bank details: {rib}'**
  String walletWithdrawRib(String rib);

  /// No description provided for @walletWithdrawDefault.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get walletWithdrawDefault;

  /// No description provided for @walletWithdrawEmptyAccounts.
  ///
  /// In en, this message translates to:
  /// **'No bank account available'**
  String get walletWithdrawEmptyAccounts;

  /// No description provided for @walletWithdrawTransferSent.
  ///
  /// In en, this message translates to:
  /// **'Your withdrawal request has been sent'**
  String get walletWithdrawTransferSent;

  /// No description provided for @walletWithdrawToAccount.
  ///
  /// In en, this message translates to:
  /// **'To account {name}'**
  String walletWithdrawToAccount(String name);

  /// No description provided for @walletWithdrawStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get walletWithdrawStatus;

  /// No description provided for @walletWithdrawProcessing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get walletWithdrawProcessing;

  /// No description provided for @walletWithdrawDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get walletWithdrawDate;

  /// No description provided for @walletWithdrawEstimatedReceptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Estimated processing time'**
  String get walletWithdrawEstimatedReceptionLabel;

  /// No description provided for @walletWithdrawEstimatedReceptionValue.
  ///
  /// In en, this message translates to:
  /// **'Depending on bank processing times'**
  String get walletWithdrawEstimatedReceptionValue;

  /// No description provided for @walletWithdrawBackToWallet.
  ///
  /// In en, this message translates to:
  /// **'Back to wallet'**
  String get walletWithdrawBackToWallet;

  /// No description provided for @walletWithdrawCashTitle.
  ///
  /// In en, this message translates to:
  /// **'Cash withdrawal'**
  String get walletWithdrawCashTitle;

  /// No description provided for @walletWithdrawAmountToWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Amount to withdraw'**
  String get walletWithdrawAmountToWithdraw;

  /// No description provided for @walletWithdrawCashBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance: {balance} MAD'**
  String walletWithdrawCashBalance(String balance);

  /// No description provided for @walletWithdrawCashDescription.
  ///
  /// In en, this message translates to:
  /// **'Withdraw your money at any Chaabi Cash, Damane Cash or Tashilat agency.'**
  String get walletWithdrawCashDescription;

  /// No description provided for @walletWithdrawFailed.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal failed. Please try again.'**
  String get walletWithdrawFailed;

  /// No description provided for @walletWithdrawConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get walletWithdrawConnectionError;

  /// No description provided for @walletWithdrawAgencyInstructions.
  ///
  /// In en, this message translates to:
  /// **'Show this code and your national ID at the counter to collect your money.'**
  String get walletWithdrawAgencyInstructions;

  /// No description provided for @walletWithdrawGetCode.
  ///
  /// In en, this message translates to:
  /// **'Get my withdrawal code'**
  String get walletWithdrawGetCode;

  /// No description provided for @walletWithdrawCodeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Show this code and your national ID at the counter to collect your money.'**
  String get walletWithdrawCodeInstructions;

  /// No description provided for @walletWithdrawCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'WITHDRAWAL CODE'**
  String get walletWithdrawCodeLabel;

  /// No description provided for @walletWithdrawAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get walletWithdrawAmountLabel;

  /// No description provided for @walletWithdrawBlockedAmountInfo.
  ///
  /// In en, this message translates to:
  /// **'The amount is reserved from your balance. If you do not withdraw it before it expires, it will be returned to your balance.'**
  String get walletWithdrawBlockedAmountInfo;

  /// No description provided for @walletWithdrawBackToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get walletWithdrawBackToHome;

  /// No description provided for @walletWithdrawChooseMethod.
  ///
  /// In en, this message translates to:
  /// **'Choose your withdrawal method'**
  String get walletWithdrawChooseMethod;

  /// No description provided for @walletWithdrawAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance: {balance} MAD'**
  String walletWithdrawAvailableBalance(String balance);

  /// No description provided for @walletWithdrawBankSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive the money in your bank account'**
  String get walletWithdrawBankSubtitle;

  /// No description provided for @walletWithdrawCashAgency.
  ///
  /// In en, this message translates to:
  /// **'Cash withdrawal'**
  String get walletWithdrawCashAgency;

  /// No description provided for @walletWithdrawCashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw money at a partner agency'**
  String get walletWithdrawCashSubtitle;

  /// No description provided for @walletWithdrawTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw money'**
  String get walletWithdrawTitle;

  /// No description provided for @quizLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading quiz...'**
  String get quizLoading;

  /// No description provided for @quizQuestionProgress.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestionProgress(String current, String total);

  /// No description provided for @quizOfTheDay.
  ///
  /// In en, this message translates to:
  /// **'Quiz of the day'**
  String get quizOfTheDay;

  /// No description provided for @quizQuestionsAboutClub.
  ///
  /// In en, this message translates to:
  /// **'{count} questions about the club'**
  String quizQuestionsAboutClub(String count);

  /// No description provided for @quizQuestionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} questions'**
  String quizQuestionsCount(String count);

  /// No description provided for @quizRewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get quizRewards;

  /// No description provided for @quizQuestionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get quizQuestionsLabel;

  /// No description provided for @quizPerQuestion.
  ///
  /// In en, this message translates to:
  /// **'Per question'**
  String get quizPerQuestion;

  /// No description provided for @quizDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get quizDuration;

  /// No description provided for @quizSeconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get quizSeconds;

  /// No description provided for @quizMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minutes'**
  String quizMinutes(String count);

  /// No description provided for @quizCorrectAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get quizCorrectAnswerLabel;

  /// No description provided for @quizYourAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get quizYourAnswerLabel;

  /// No description provided for @quizAnswerQuickly.
  ///
  /// In en, this message translates to:
  /// **'Answer quickly!'**
  String get quizAnswerQuickly;

  /// No description provided for @quizGoodAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct answers'**
  String get quizGoodAnswers;

  /// No description provided for @quizPoints.
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String quizPoints(String points);

  /// No description provided for @quizParticipatingInDraw.
  ///
  /// In en, this message translates to:
  /// **'You are entered into the prize draw'**
  String get quizParticipatingInDraw;

  /// No description provided for @quizDefaultReward.
  ///
  /// In en, this message translates to:
  /// **'Quiz reward'**
  String get quizDefaultReward;

  /// No description provided for @quizBackHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get quizBackHome;

  /// No description provided for @quizScoreSaved.
  ///
  /// In en, this message translates to:
  /// **'Your score of {score}/{total} has been saved'**
  String quizScoreSaved(String score, String total);

  /// No description provided for @quizTomorrowAt.
  ///
  /// In en, this message translates to:
  /// **'Next quiz tomorrow at'**
  String get quizTomorrowAt;

  /// No description provided for @quizCorrectAnswerExplanation.
  ///
  /// In en, this message translates to:
  /// **'The correct answer is: {answer}'**
  String quizCorrectAnswerExplanation(String answer);

  /// No description provided for @myAccount.
  ///
  /// In en, this message translates to:
  /// **'My account'**
  String get myAccount;

  /// No description provided for @defaultAccountType.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get defaultAccountType;

  /// No description provided for @namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get namePlaceholder;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountType;

  /// No description provided for @accountLevel.
  ///
  /// In en, this message translates to:
  /// **'Account level'**
  String get accountLevel;

  /// No description provided for @accountLevelWithValue.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String accountLevelWithValue(String level);

  /// No description provided for @accountLimit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get accountLimit;

  /// No description provided for @identityVerification.
  ///
  /// In en, this message translates to:
  /// **'Identity verification'**
  String get identityVerification;

  /// No description provided for @kycPhoneVerified.
  ///
  /// In en, this message translates to:
  /// **'Phone verified'**
  String get kycPhoneVerified;

  /// No description provided for @kycPersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get kycPersonalInfo;

  /// No description provided for @kycAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get kycAddress;

  /// No description provided for @kycCin.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get kycCin;

  /// No description provided for @kycSelfie.
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get kycSelfie;

  /// No description provided for @changePin.
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin;

  /// No description provided for @logoutWalletSession.
  ///
  /// In en, this message translates to:
  /// **'Log out of wallet'**
  String get logoutWalletSession;

  /// No description provided for @walletSessionClosed.
  ///
  /// In en, this message translates to:
  /// **'Wallet session closed'**
  String get walletSessionClosed;

  /// No description provided for @addAccountInMyName.
  ///
  /// In en, this message translates to:
  /// **'Add an account in my name'**
  String get addAccountInMyName;

  /// No description provided for @addAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a bank account in your name to perform your transactions easily.'**
  String get addAccountSubtitle;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Account name'**
  String get accountNameLabel;

  /// No description provided for @ribLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank account number (RIB)'**
  String get ribLabel;

  /// No description provided for @useWalletPhone.
  ///
  /// In en, this message translates to:
  /// **'Use wallet phone number'**
  String get useWalletPhone;

  /// No description provided for @associatedPhoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Associated phone number'**
  String get associatedPhoneLabel;

  /// No description provided for @phoneHintShort.
  ///
  /// In en, this message translates to:
  /// **'6 12 34 56 78'**
  String get phoneHintShort;

  /// No description provided for @ribWarning.
  ///
  /// In en, this message translates to:
  /// **'Check your bank account number carefully before saving. It cannot be changed afterwards.'**
  String get ribWarning;

  /// No description provided for @saveThisAccount.
  ///
  /// In en, this message translates to:
  /// **'Save this account'**
  String get saveThisAccount;

  /// No description provided for @newBankAccount.
  ///
  /// In en, this message translates to:
  /// **'New bank account'**
  String get newBankAccount;

  /// No description provided for @ribMustBe24Digits.
  ///
  /// In en, this message translates to:
  /// **'The bank account number must contain 24 digits'**
  String get ribMustBe24Digits;

  /// No description provided for @addBeneficiaryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to add account'**
  String get addBeneficiaryFailed;

  /// No description provided for @receivePayment.
  ///
  /// In en, this message translates to:
  /// **'Receive payment'**
  String get receivePayment;

  /// No description provided for @accountManagement.
  ///
  /// In en, this message translates to:
  /// **'Account management'**
  String get accountManagement;

  /// No description provided for @payBill.
  ///
  /// In en, this message translates to:
  /// **'Pay a bill'**
  String get payBill;

  /// No description provided for @payMerchant.
  ///
  /// In en, this message translates to:
  /// **'Pay a merchant'**
  String get payMerchant;

  /// No description provided for @giftCards.
  ///
  /// In en, this message translates to:
  /// **'Gift cards'**
  String get giftCards;

  /// No description provided for @myCards.
  ///
  /// In en, this message translates to:
  /// **'My cards'**
  String get myCards;

  /// No description provided for @availableSection.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableSection;

  /// No description provided for @soonSection.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get soonSection;

  /// No description provided for @soonLabel.
  ///
  /// In en, this message translates to:
  /// **'SOON'**
  String get soonLabel;

  /// No description provided for @comingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'{label} coming soon'**
  String comingSoonMessage(String label);

  /// No description provided for @allServices.
  ///
  /// In en, this message translates to:
  /// **'All services'**
  String get allServices;

  /// No description provided for @mobileRecharge.
  ///
  /// In en, this message translates to:
  /// **'Mobile top-up'**
  String get mobileRecharge;

  /// No description provided for @topUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get topUp;

  /// No description provided for @transferAction.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferAction;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @myWalletAccounts.
  ///
  /// In en, this message translates to:
  /// **'My wallet accounts'**
  String get myWalletAccounts;

  /// No description provided for @eachAccountLinkedToPhone.
  ///
  /// In en, this message translates to:
  /// **'Each account is linked to a phone number.'**
  String get eachAccountLinkedToPhone;

  /// No description provided for @phoneMaskPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'•••• •••• ••'**
  String get phoneMaskPlaceholder;

  /// No description provided for @accountHolderBalance.
  ///
  /// In en, this message translates to:
  /// **'{holder} · {balance} MAD'**
  String accountHolderBalance(String holder, String balance);

  /// No description provided for @holder.
  ///
  /// In en, this message translates to:
  /// **'Account holder'**
  String get holder;

  /// No description provided for @balancePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get balancePlaceholder;

  /// No description provided for @accountAddSoon.
  ///
  /// In en, this message translates to:
  /// **'Adding another account will be available soon'**
  String get accountAddSoon;

  /// No description provided for @addWalletAccount.
  ///
  /// In en, this message translates to:
  /// **'Add wallet account'**
  String get addWalletAccount;

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyTitle;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @filterRecharges.
  ///
  /// In en, this message translates to:
  /// **'Top-ups'**
  String get filterRecharges;

  /// No description provided for @filterSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get filterSent;

  /// No description provided for @filterReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get filterReceived;

  /// No description provided for @filterCashOut.
  ///
  /// In en, this message translates to:
  /// **'Cash out'**
  String get filterCashOut;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get noTransactions;

  /// No description provided for @levelLabel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get levelLabel;

  /// No description provided for @subscriptionComingSoonMessage.
  ///
  /// In en, this message translates to:
  /// **'Wydad Pay subscription will be available soon. Stay tuned!'**
  String get subscriptionComingSoonMessage;

  /// No description provided for @digitalWallet.
  ///
  /// In en, this message translates to:
  /// **'DIGITAL WALLET'**
  String get digitalWallet;

  /// No description provided for @verifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get verifiedBadge;

  /// No description provided for @availableBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get availableBalanceLabel;

  /// No description provided for @moreAction.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreAction;

  /// No description provided for @latestOperations.
  ///
  /// In en, this message translates to:
  /// **'Latest operations'**
  String get latestOperations;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noOperation.
  ///
  /// In en, this message translates to:
  /// **'No operation'**
  String get noOperation;

  /// No description provided for @subscriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get subscriptionLabel;

  /// No description provided for @season2026_27.
  ///
  /// In en, this message translates to:
  /// **'Season 2026/27'**
  String get season2026_27;

  /// No description provided for @supporterNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Supporter name'**
  String get supporterNamePlaceholder;

  /// No description provided for @tribuneInfoPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tribune • Seat'**
  String get tribuneInfoPlaceholder;

  /// No description provided for @showQRAccess.
  ///
  /// In en, this message translates to:
  /// **'Show QR access'**
  String get showQRAccess;

  /// No description provided for @nextMatch.
  ///
  /// In en, this message translates to:
  /// **'Next match'**
  String get nextMatch;

  /// No description provided for @resellMatch.
  ///
  /// In en, this message translates to:
  /// **'Resell match'**
  String get resellMatch;

  /// No description provided for @subscriptionDetails.
  ///
  /// In en, this message translates to:
  /// **'Subscription details'**
  String get subscriptionDetails;

  /// No description provided for @renewSubscription.
  ///
  /// In en, this message translates to:
  /// **'Renew subscription'**
  String get renewSubscription;

  /// No description provided for @amountToDeposit.
  ///
  /// In en, this message translates to:
  /// **'Amount to deposit'**
  String get amountToDeposit;

  /// No description provided for @cashAgencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Cash deposit at an agency'**
  String get cashAgencyDescription;

  /// No description provided for @minAmount50.
  ///
  /// In en, this message translates to:
  /// **'The minimum amount is 50 MAD'**
  String get minAmount50;

  /// No description provided for @operationFailedContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. Please contact support.'**
  String get operationFailedContactSupport;

  /// No description provided for @connectionErrorRetry.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Please try again.'**
  String get connectionErrorRetry;

  /// No description provided for @cashAgencyInfo.
  ///
  /// In en, this message translates to:
  /// **'Show the code and your ID at any partner agency (Chaabi Cash, Damane Cash, Tashilat) to complete the deposit.'**
  String get cashAgencyInfo;

  /// No description provided for @getMyDepositCode.
  ///
  /// In en, this message translates to:
  /// **'Get my deposit code'**
  String get getMyDepositCode;

  /// No description provided for @presentCodeAndCin.
  ///
  /// In en, this message translates to:
  /// **'Show this code and your national ID at the counter.'**
  String get presentCodeAndCin;

  /// No description provided for @depositCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'DEPOSIT CODE'**
  String get depositCodeLabel;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @balanceWillBeCredited.
  ///
  /// In en, this message translates to:
  /// **'The amount will be credited to your balance once the deposit is verified.'**
  String get balanceWillBeCredited;

  /// No description provided for @cardsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cards'**
  String get cardsLoadFailed;

  /// No description provided for @amountBetween50And1000.
  ///
  /// In en, this message translates to:
  /// **'The amount must be between 50 and 1000 MAD'**
  String get amountBetween50And1000;

  /// No description provided for @loadingCardsInProgress.
  ///
  /// In en, this message translates to:
  /// **'Loading cards...'**
  String get loadingCardsInProgress;

  /// No description provided for @noSavedCard.
  ///
  /// In en, this message translates to:
  /// **'No saved card'**
  String get noSavedCard;

  /// No description provided for @pleaseSelectCard.
  ///
  /// In en, this message translates to:
  /// **'Please select a card'**
  String get pleaseSelectCard;

  /// No description provided for @invalidCvv.
  ///
  /// In en, this message translates to:
  /// **'Invalid CVV'**
  String get invalidCvv;

  /// No description provided for @genericErrorContactSupport.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please contact support.'**
  String get genericErrorContactSupport;

  /// No description provided for @paymentCancelledOrFailed.
  ///
  /// In en, this message translates to:
  /// **'Payment cancelled or failed'**
  String get paymentCancelledOrFailed;

  /// No description provided for @updatingBalance.
  ///
  /// In en, this message translates to:
  /// **'Updating balance...'**
  String get updatingBalance;

  /// No description provided for @rechargeAction.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get rechargeAction;

  /// No description provided for @topUpYourWalletAmount.
  ///
  /// In en, this message translates to:
  /// **'Top up your wallet'**
  String get topUpYourWalletAmount;

  /// No description provided for @transactionLimitLevel1.
  ///
  /// In en, this message translates to:
  /// **'Transaction limit: 1000 MAD (Level 1)'**
  String get transactionLimitLevel1;

  /// No description provided for @totalToPay.
  ///
  /// In en, this message translates to:
  /// **'Total to pay'**
  String get totalToPay;

  /// No description provided for @loadingCards.
  ///
  /// In en, this message translates to:
  /// **'Loading cards...'**
  String get loadingCards;

  /// No description provided for @retryLoadCards.
  ///
  /// In en, this message translates to:
  /// **'Retry loading cards'**
  String get retryLoadCards;

  /// No description provided for @noCardRefresh.
  ///
  /// In en, this message translates to:
  /// **'No card. Tap to refresh'**
  String get noCardRefresh;

  /// No description provided for @paymentCard.
  ///
  /// In en, this message translates to:
  /// **'Payment card'**
  String get paymentCard;

  /// No description provided for @selectCardToPay.
  ///
  /// In en, this message translates to:
  /// **'Select the card to pay {amount} MAD'**
  String selectCardToPay(String amount);

  /// No description provided for @noSavedCards.
  ///
  /// In en, this message translates to:
  /// **'No saved cards'**
  String get noSavedCards;

  /// No description provided for @addCardFromProfile.
  ///
  /// In en, this message translates to:
  /// **'Add a card from your profile'**
  String get addCardFromProfile;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @cardDefault.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get cardDefault;

  /// No description provided for @maskedPanPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'•••• •••• •••• ••••'**
  String get maskedPanPlaceholder;

  /// No description provided for @confirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment confirmation'**
  String get confirmationTitle;

  /// No description provided for @enterCvvPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your card\'s CVV'**
  String get enterCvvPrompt;

  /// No description provided for @cvvHint.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvvHint;

  /// No description provided for @rechargeDone.
  ///
  /// In en, this message translates to:
  /// **'Top-up complete!'**
  String get rechargeDone;

  /// No description provided for @rechargeSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your wallet has been topped up successfully.'**
  String get rechargeSuccessMessage;

  /// No description provided for @rechargedAmount.
  ///
  /// In en, this message translates to:
  /// **'Recharged amount'**
  String get rechargedAmount;

  /// No description provided for @newBalance.
  ///
  /// In en, this message translates to:
  /// **'New balance'**
  String get newBalance;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join the Wydad community and access all features'**
  String get registerSubtitle;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint;

  /// No description provided for @phoneVerificationNote.
  ///
  /// In en, this message translates to:
  /// **'A verification code will be sent to this number'**
  String get phoneVerificationNote;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get passwordMinHint;

  /// No description provided for @passwordStrengthHint.
  ///
  /// In en, this message translates to:
  /// **'Use letters, numbers and symbols for a strong password'**
  String get passwordStrengthHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @acceptTermsText.
  ///
  /// In en, this message translates to:
  /// **'I accept the terms and conditions'**
  String get acceptTermsText;

  /// No description provided for @acceptTermsRequired.
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms and conditions'**
  String get acceptTermsRequired;

  /// No description provided for @createMyAccount.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get createMyAccount;

  /// No description provided for @alreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? '**
  String get alreadyRegistered;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginLink;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log in to access your tickets and wallet'**
  String get loginSubtitle;

  /// No description provided for @passwordHintLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHintLogin;

  /// No description provided for @noAccountYet.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get noAccountYet;

  /// No description provided for @createAccountLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get createAccountLink;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In en, this message translates to:
  /// **'All your tickets in one place'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide1Text.
  ///
  /// In en, this message translates to:
  /// **'Buy, transfer and manage your Wydad match tickets directly from the app.'**
  String get onboardingSlide1Text;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In en, this message translates to:
  /// **'Wydad Pay, your digital wallet'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide2Text.
  ///
  /// In en, this message translates to:
  /// **'Top up, transfer and pay easily with your secure Wydad Pay wallet.'**
  String get onboardingSlide2Text;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In en, this message translates to:
  /// **'Live the Wydad experience'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide3Text.
  ///
  /// In en, this message translates to:
  /// **'Vote for your man of the match, play quizzes and win exclusive prizes.'**
  String get onboardingSlide3Text;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @continueWithoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Continue without account'**
  String get continueWithoutAccount;

  /// No description provided for @mockTicketplace.
  ///
  /// In en, this message translates to:
  /// **'TICKETPLACE'**
  String get mockTicketplace;

  /// No description provided for @mockResale.
  ///
  /// In en, this message translates to:
  /// **'Resale between fans'**
  String get mockResale;

  /// No description provided for @mockFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get mockFrom;

  /// No description provided for @mockFanZone.
  ///
  /// In en, this message translates to:
  /// **'FAN ZONE'**
  String get mockFanZone;

  /// No description provided for @mockManOfMatch.
  ///
  /// In en, this message translates to:
  /// **'Man of the match'**
  String get mockManOfMatch;

  /// No description provided for @mockLiveVote.
  ///
  /// In en, this message translates to:
  /// **'LIVE VOTE'**
  String get mockLiveVote;

  /// No description provided for @mockTicket.
  ///
  /// In en, this message translates to:
  /// **'TICKET'**
  String get mockTicket;

  /// No description provided for @mockPremium.
  ///
  /// In en, this message translates to:
  /// **'PREMIUM'**
  String get mockPremium;

  /// No description provided for @mockStadium.
  ///
  /// In en, this message translates to:
  /// **'Stadium'**
  String get mockStadium;

  /// No description provided for @mockGateSeat.
  ///
  /// In en, this message translates to:
  /// **'Gate A · Seat 24'**
  String get mockGateSeat;

  /// No description provided for @mockSubscription.
  ///
  /// In en, this message translates to:
  /// **'SUBSCRIPTION'**
  String get mockSubscription;

  /// No description provided for @mockSeason.
  ///
  /// In en, this message translates to:
  /// **'Season 2026/27'**
  String get mockSeason;

  /// No description provided for @mockWydadPay.
  ///
  /// In en, this message translates to:
  /// **'WYDAD PAY'**
  String get mockWydadPay;

  /// No description provided for @mockAvailableBalance.
  ///
  /// In en, this message translates to:
  /// **'Available balance'**
  String get mockAvailableBalance;

  /// No description provided for @mockTopUp.
  ///
  /// In en, this message translates to:
  /// **'Top up'**
  String get mockTopUp;

  /// No description provided for @mockTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get mockTransfer;

  /// No description provided for @mockWithdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get mockWithdraw;

  /// No description provided for @mockMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get mockMore;

  /// No description provided for @mockMatchPlayer.
  ///
  /// In en, this message translates to:
  /// **'Man of the match'**
  String get mockMatchPlayer;

  /// No description provided for @mockLive.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get mockLive;

  /// No description provided for @mockQuizOfDay.
  ///
  /// In en, this message translates to:
  /// **'Quiz of the day'**
  String get mockQuizOfDay;

  /// No description provided for @mockWinTickets.
  ///
  /// In en, this message translates to:
  /// **'Win tickets'**
  String get mockWinTickets;

  /// No description provided for @chooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get chooseCategory;

  /// No description provided for @quantityRequestedExceedsStock.
  ///
  /// In en, this message translates to:
  /// **'Requested: {requested}, available: {available}'**
  String quantityRequestedExceedsStock(String requested, String available);

  /// No description provided for @productUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Product unavailable'**
  String get productUnavailable;

  /// No description provided for @maillotsOfficiel.
  ///
  /// In en, this message translates to:
  /// **'OFFICIAL JERSEY'**
  String get maillotsOfficiel;

  /// No description provided for @visaMastercard3ds.
  ///
  /// In en, this message translates to:
  /// **'Visa / Mastercard · 3D Secure'**
  String get visaMastercard3ds;

  /// No description provided for @wydadPayLabel.
  ///
  /// In en, this message translates to:
  /// **'Wydad Pay'**
  String get wydadPayLabel;

  /// No description provided for @stadiumName.
  ///
  /// In en, this message translates to:
  /// **'Stade Mohammed V'**
  String get stadiumName;

  /// No description provided for @transfersButton.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get transfersButton;

  /// No description provided for @matchPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get matchPlaceholder;

  /// No description provided for @pendingTransferLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending transfers ({count})'**
  String pendingTransferLabel(String count);

  /// No description provided for @senderPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get senderPlaceholder;

  /// No description provided for @receivedTicketFrom.
  ///
  /// In en, this message translates to:
  /// **'Ticket received from {name}'**
  String receivedTicketFrom(String name);

  /// No description provided for @inPendingLabel.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get inPendingLabel;

  /// No description provided for @transferAcceptInfo.
  ///
  /// In en, this message translates to:
  /// **'Accept the transfer to receive the ticket in your account.'**
  String get transferAcceptInfo;

  /// No description provided for @refuse.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get refuse;

  /// No description provided for @myOrdersSection.
  ///
  /// In en, this message translates to:
  /// **'My orders ({count})'**
  String myOrdersSection(String count);

  /// No description provided for @paidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paidLabel;

  /// No description provided for @receivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get receivedLabel;

  /// No description provided for @transferredLabel.
  ///
  /// In en, this message translates to:
  /// **'Transferred'**
  String get transferredLabel;

  /// No description provided for @walletLabel.
  ///
  /// In en, this message translates to:
  /// **'Wydad Pay'**
  String get walletLabel;

  /// No description provided for @paidOnPayment.
  ///
  /// In en, this message translates to:
  /// **'Paid on {date} · via {method}'**
  String paidOnPayment(String date, String method);

  /// No description provided for @ticketFallback.
  ///
  /// In en, this message translates to:
  /// **'Ticket'**
  String get ticketFallback;

  /// No description provided for @validLabel.
  ///
  /// In en, this message translates to:
  /// **'Valid'**
  String get validLabel;

  /// No description provided for @ticketNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'N°{number}'**
  String ticketNumberLabel(String number);

  /// No description provided for @billetterie.
  ///
  /// In en, this message translates to:
  /// **'TICKETING'**
  String get billetterie;

  /// No description provided for @maxPerAccount.
  ///
  /// In en, this message translates to:
  /// **'max per account'**
  String get maxPerAccount;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @soldOut.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get soldOut;

  /// No description provided for @fewSeatsLeft.
  ///
  /// In en, this message translates to:
  /// **'Few seats left'**
  String get fewSeatsLeft;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethodLabel;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get insufficientBalance;

  /// No description provided for @pinCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN code'**
  String get pinCodeLabel;

  /// No description provided for @pinCodeHint.
  ///
  /// In en, this message translates to:
  /// **'4-digit PIN'**
  String get pinCodeHint;

  /// No description provided for @cardBankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank card'**
  String get cardBankLabel;

  /// No description provided for @payByCard.
  ///
  /// In en, this message translates to:
  /// **'Pay securely by card'**
  String get payByCard;

  /// No description provided for @pinRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter your 4-digit PIN'**
  String get pinRequired;

  /// No description provided for @genericErrorMsg.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get genericErrorMsg;

  /// No description provided for @processingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing payment...'**
  String get processingTitle;

  /// No description provided for @processingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please wait a moment'**
  String get processingSubtitle;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully.'**
  String get paymentSuccessMessage;

  /// No description provided for @backToEvents.
  ///
  /// In en, this message translates to:
  /// **'Back to events'**
  String get backToEvents;

  /// No description provided for @myInfoSection.
  ///
  /// In en, this message translates to:
  /// **'MY INFORMATION'**
  String get myInfoSection;

  /// No description provided for @passwordSection.
  ///
  /// In en, this message translates to:
  /// **'PASSWORD'**
  String get passwordSection;

  /// No description provided for @supporterWac.
  ///
  /// In en, this message translates to:
  /// **'WAC Supporter'**
  String get supporterWac;

  /// No description provided for @cinHintFull.
  ///
  /// In en, this message translates to:
  /// **'Ex: BK123456'**
  String get cinHintFull;

  /// No description provided for @newPasswordHintMin.
  ///
  /// In en, this message translates to:
  /// **'Minimum 8 characters, 1 uppercase, 1 lowercase, 1 number'**
  String get newPasswordHintMin;

  /// No description provided for @inProgressSection.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get inProgressSection;

  /// No description provided for @previousSection.
  ///
  /// In en, this message translates to:
  /// **'PREVIOUS'**
  String get previousSection;

  /// No description provided for @myOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrdersTitle;

  /// No description provided for @orderLabel.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get orderLabel;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} item(s)'**
  String itemsCount(String count);

  /// No description provided for @passedOn.
  ///
  /// In en, this message translates to:
  /// **'Placed on'**
  String get passedOn;

  /// No description provided for @deliveryExpected.
  ///
  /// In en, this message translates to:
  /// **'Estimated delivery'**
  String get deliveryExpected;

  /// No description provided for @carrier.
  ///
  /// In en, this message translates to:
  /// **'Carrier'**
  String get carrier;

  /// No description provided for @carrierName.
  ///
  /// In en, this message translates to:
  /// **'Wydad Express'**
  String get carrierName;

  /// No description provided for @deliveredStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveredStatus;

  /// No description provided for @stepConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get stepConfirmed;

  /// No description provided for @stepPrepared.
  ///
  /// In en, this message translates to:
  /// **'Prepared'**
  String get stepPrepared;

  /// No description provided for @stepShipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get stepShipped;

  /// No description provided for @stepDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get stepDelivered;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @paymentLabel.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentLabel;

  /// No description provided for @deliveryInfoSection.
  ///
  /// In en, this message translates to:
  /// **'DELIVERY INFO'**
  String get deliveryInfoSection;

  /// No description provided for @daysShort.
  ///
  /// In en, this message translates to:
  /// **'d'**
  String get daysShort;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get hoursShort;

  /// No description provided for @transferTicketTitle.
  ///
  /// In en, this message translates to:
  /// **'Transfer ticket'**
  String get transferTicketTitle;

  /// No description provided for @transferTicketPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter the recipient\'s email address'**
  String get transferTicketPrompt;

  /// No description provided for @errorCustomerId.
  ///
  /// In en, this message translates to:
  /// **'Error: customer ID missing'**
  String get errorCustomerId;

  /// No description provided for @transferDone.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed'**
  String get transferDone;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @ticketDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Ticket details'**
  String get ticketDetailTitle;

  /// No description provided for @ticketStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Ticket status'**
  String get ticketStatusLabel;

  /// No description provided for @transferTicket.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferTicket;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet;

  /// No description provided for @referenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get referenceLabel;
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
