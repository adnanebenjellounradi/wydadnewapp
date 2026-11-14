// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get editProfileTitle => 'تعديل المعلومات الشخصية';

  @override
  String get firstNameLabel => 'الاسم الشخصي';

  @override
  String get firstNameRequired => 'الاسم الشخصي مطلوب';

  @override
  String get firstNameLettersOnly => 'الاسم الشخصي يجب أن يحتوي على حروف فقط';

  @override
  String get firstNameMinLength => 'الاسم الشخصي يجب أن يحتوي على حرفين على الأقل';

  @override
  String get lastNameLabel => 'الإسم العائلي';

  @override
  String get lastNameRequired => 'الإسم العائلي مطلوب';

  @override
  String get lastNameLettersOnly => 'الإسم العائلي يجب أن يحتوي على حروف فقط';

  @override
  String get lastNameMinLength => 'الإسم العائلي يجب أن يحتوي على حرفين على الأقل';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get phoneLabel => 'رقم الهاتف';

  @override
  String get phoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get phoneInvalid => 'يجب أن يبدأ الرقم بـ 6 أو 7 ويتكون من 9 أرقام';

  @override
  String get phoneHint => '6 12 34 56 78';

  @override
  String get cinLabel => 'رقم البطاقة الوطنية';

  @override
  String get cinMinLength => '5 أحرف على الأقل';

  @override
  String get currentPasswordLabel => 'كلمة المرور الحالية';

  @override
  String get currentPasswordRequired => 'كلمة المرور الحالية مطلوبة لتغيير كلمة المرور';

  @override
  String get newPasswordLabel => 'كلمة المرور الجديدة';

  @override
  String get passwordMinLength => 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل';

  @override
  String get passwordRequirements => 'يجب أن تحتوي كلمة المرور على حرف صغير وحرف كبير ورقم واحد على الأقل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get errorLoadingProfile => 'خطأ في تحميل الملف الشخصي';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get updateProfileFailed => 'فشل تحديث الملف الشخصي';

  @override
  String get errorUpdatingProfile => 'خطأ في تحديث الملف الشخصي';

  @override
  String get emailCannotBeChanged => 'لا يمكن تغيير البريد الإلكتروني. اتصل بالدعم لتعديل عنوان البريد الإلكتروني.';

  @override
  String get emailCannotBeChangedShort => 'لا يمكن تغيير البريد الإلكتروني';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع المظلم';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'English';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String enterYour(Object label) {
    return 'أدخل $label الخاص بك';
  }

  @override
  String get allCategories => 'جميع الفئات';

  @override
  String get allSizes => 'جميع المقاسات';

  @override
  String get seeMyOrders => 'عرض طلباتي';

  @override
  String get store => 'المتجر';

  @override
  String get storeTitle => 'المتجر';

  @override
  String get outOfStock => 'نفد من المخزون';

  @override
  String get addToCart => 'أضف إلى السلة';

  @override
  String get viewCart => 'عرض السلة';

  @override
  String get noProductsFound => 'لم يتم العثور على منتجات';

  @override
  String get productAddedToCart => 'تمت إضافة المنتج إلى السلة';

  @override
  String get orderSummary => 'ملخص طلبك';

  @override
  String get verifyItemsBeforeContinuing => 'تحقق من العناصر المحددة قبل المتابعة:';

  @override
  String get cartIsEmpty => 'سلتك فارغة';

  @override
  String get size => 'المقاس';

  @override
  String get sizeLabel => 'المقاس:';

  @override
  String get quantity => 'الكمية';

  @override
  String get productsTotal => 'إجمالي المنتجات';

  @override
  String get modify => 'تعديل';

  @override
  String get continueText => 'متابعة';

  @override
  String get deliveryInformation => 'معلومات التسليم';

  @override
  String get fullNameHint => 'اسمك الكامل';

  @override
  String get fullAddress => 'العنوان الكامل';

  @override
  String get addressHint => 'الشارع، المدينة، الرمز البريدي...';

  @override
  String get deliveryType => 'نوع التوصيل';

  @override
  String get casablanca => 'الدار البيضاء';

  @override
  String get otherCities => 'مدن أخرى';

  @override
  String get productsSubtotal => 'المجموع الفرعي للمنتجات';

  @override
  String get deliveryFee => 'رسوم التوصيل';

  @override
  String get total => 'الإجمالي';

  @override
  String get back => 'رجوع';

  @override
  String get finalOrderSummary => 'الملخص النهائي للطلب';

  @override
  String get orderedItems => 'العناصر المطلوبة';

  @override
  String get verifyOrderInfo => 'يرجى التحقق من جميع المعلومات قبل تأكيد طلبك.';

  @override
  String get pay => 'ادفع';

  @override
  String get orderConfirmed => 'تم تأكيد الطلب!';

  @override
  String get orderSuccessMessage => 'تم تقديم طلبك بنجاح. ستتلقى اتصالاً لتأكيد التوصيل.';

  @override
  String get close => 'إغلاق';

  @override
  String get error => 'خطأ';

  @override
  String get ok => 'حسناً';

  @override
  String get unavailableProducts => 'منتجات غير متوفرة';

  @override
  String get loginRequired => 'تسجيل الدخول مطلوب';

  @override
  String get loginToAccess => 'سجل الدخول للوصول إلى هذه الميزة.';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get noAccountSignUp => 'ليس لديك حساب؟ سجل الآن';

  @override
  String get productDetails => 'تفاصيل المنتج';

  @override
  String get description => 'الوصف';

  @override
  String get availableSizes => 'المقاسات المتاحة';

  @override
  String get fullNameRequired => 'الاسم الكامل *';

  @override
  String get fullNameLettersOnly => 'يجب أن يحتوي الاسم الكامل على حروف فقط';

  @override
  String get fullNameMinLength => 'يجب أن يحتوي الاسم الكامل على حرفين على الأقل';

  @override
  String get addressRequired => 'عنوان التسليم مطلوب';

  @override
  String get addressMinLength => 'يجب أن يكون العنوان أكثر تفصيلاً (10 أحرف على الأقل)';

  @override
  String get errorLoadingProductDetails => 'خطأ في تحميل تفاصيل المنتج';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get confirmRemoveProduct => 'هل تريد حقًا إزالة هذا المنتج من السلة؟';

  @override
  String get delete => 'حذف';

  @override
  String get productImage => 'صورة المنتج';

  @override
  String get totalAmount => 'المبلغ الإجمالي';

  @override
  String get fees => 'الرسوم';

  @override
  String get delivery => 'التوصيل';

  @override
  String get selectSize => 'اختر المقاس';

  @override
  String get selectQuantity => 'اختر الكمية';

  @override
  String get price => 'السعر';

  @override
  String get subtotal => 'المجموع الفرعي';

  @override
  String get orderNumber => 'رقم الطلب';

  @override
  String get orderDate => 'تاريخ الطلب';

  @override
  String get orderStatus => 'حالة الطلب';

  @override
  String get paymentMethod => 'طريقة الدفع';

  @override
  String get paymentStatus => 'حالة الدفع';

  @override
  String get trackOrder => 'تتبع الطلب';

  @override
  String get contactSupport => 'اتصل بالدعم إذا كنت تعتقد أن هذا خطأ.';

  @override
  String get termsAndConditions => 'الشروط والأحكام';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get aboutUs => 'معلومات عنا';

  @override
  String get contactUs => 'اتصل بنا';

  @override
  String get faq => 'الأسئلة الشائعة';

  @override
  String get help => 'المساعدة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get version => 'الإصدار';

  @override
  String get rateApp => 'قيم التطبيق';

  @override
  String get shareApp => 'شارك التطبيق';

  @override
  String get followUs => 'تابعنا';

  @override
  String get search => 'بحث';

  @override
  String get filter => 'تصفية';

  @override
  String get sort => 'ترتيب';

  @override
  String get apply => 'تطبيق';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get success => 'نجاح';

  @override
  String get warning => 'تحذير';

  @override
  String get info => 'معلومات';

  @override
  String get confirm => 'تأكيد';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get done => 'تم';

  @override
  String get submit => 'إرسال';

  @override
  String get update => 'تحديث';

  @override
  String get create => 'إنشاء';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get remove => 'إزالة';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get discardChanges => 'تجاهل التغييرات';

  @override
  String get confirmDeleteAccount => 'هل أنت متأكد من رغبتك في حذف حسابك؟ هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get deleteAccountWarning => 'تحذير: حذف الحساب سيؤدي إلى فقدان جميع بياناتك بشكل دائم.';

  @override
  String get accountDeletedSuccess => 'تم حذف الحساب بنجاح';

  @override
  String get accountDeletionFailed => 'فشل حذف الحساب';

  @override
  String get sessionExpired => 'انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى';

  @override
  String get networkError => 'خطأ في الشبكة، يرجى التحقق من اتصالك بالإنترنت';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get unauthorized => 'غير مصرح به، يرجى تسجيل الدخول';

  @override
  String get forbidden => 'ليس لديك صلاحية للوصول إلى هذا المورد';

  @override
  String get notFound => 'المورد غير موجود';

  @override
  String get validationError => 'خطأ في التحقق من صحة البيانات';

  @override
  String get uploadImage => 'رفع صورة';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get chooseFromGallery => 'اختر من المعرض';

  @override
  String get cameraPermissionRequired => 'صلاحية الكاميرا مطلوبة';

  @override
  String get galleryPermissionRequired => 'صلاحية المعرض مطلوبة';

  @override
  String get home => 'الرئيسية';

  @override
  String get events => 'المبارايات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get shopUnderMaintenance => 'المتجر قيد الصيانة حالياً.';

  @override
  String get upcoming => 'القادمة';

  @override
  String get past => 'السابقة';

  @override
  String get all => 'الكل';

  @override
  String get noEventsAvailable => 'لا توجد فعاليات متاحة!';

  @override
  String get closedOn => 'أغلق في';

  @override
  String get startsOn => 'يبدأ في';

  @override
  String get closed => 'مغلق';

  @override
  String get buy => 'شراء';

  @override
  String get vote => 'تصويت';

  @override
  String get myTickets => 'تذاكري';

  @override
  String get ticket => 'تذكرة';

  @override
  String get maxPerOrder => 'الحد الأقصى لكل طلب:';

  @override
  String get buyTickets => 'شراء التذاكر';

  @override
  String get eventNotFound => 'المباراة غير موجودة!';

  @override
  String get pleaseTryAgainLater => 'يرجى المحاولة مرة أخرى لاحقاً';

  @override
  String get eventClosed => 'المباراة مغلقة';

  @override
  String get eventClosedMessage => 'هذه المباراة لم تعد تقبل حجوزات جديدة.';

  @override
  String get availableTickets => 'التذاكر المتاحة';

  @override
  String get selectNumberOfTickets => 'اختر عدد التذاكر المطلوبة';

  @override
  String get proceedToPayment => 'المتابعة للدفع';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get enterPersonalInfoToFinalizeOrder => 'يرجى إدخال معلوماتك لإتمام طلبك';

  @override
  String get fullNameInvalid => 'الاسم الكامل غير صالح (4 أحرف على الأقل، كلمتان على الأقل، بدون أرقام)';

  @override
  String get cinRequired => 'بطاقة الهوية الوطنية (CIN) *';

  @override
  String get cinHint => 'مثال: BK122456';

  @override
  String get cinInvalid => 'CIN غير صالح: يجب أن يبدأ بحرف أو حرفين، متبوعاً بـ 5 أرقام على الأقل';

  @override
  String get orderNumberMissing => 'خطأ: رقم الطلب مفقود';

  @override
  String get orderCreationFailed => 'فشل إنشاء الطلب';

  @override
  String get orderCreationError => 'خطأ في إنشاء الطلب';

  @override
  String get connectionError => 'خطأ في الاتصال. يرجى المحاولة مرة أخرى.';

  @override
  String get categoryRestriction => 'تقييد الفئة';

  @override
  String get categoryRestrictionMessage => 'يمكنك شراء فئة تذكرة واحدة فقط. يرجى إعادة تعيين كمية تذكرتك السابقة إلى 0 لإضافة هذه التذكرة.';

  @override
  String get event => 'مباراة';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get enterEmailToReceiveCode => 'أدخل عنوان بريدك الإلكتروني لتلقي رمز إعادة التعيين.';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get enterCodeAndNewPassword => 'أدخل الرمز المستلم عبر البريد الإلكتروني وكلمة المرور الجديدة.';

  @override
  String get resetCode => 'رمز إعادة التعيين';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get changeEmail => 'تغيير البريد الإلكتروني';

  @override
  String get resetCodeInfo => 'رمز إعادة التعيين صالح لمدة ساعة واحدة. تأكد من التحقق من صندوق الوارد والبريد المزعج.';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get invalidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get resetCodeRequired => 'رمز إعادة التعيين مطلوب';

  @override
  String get resetCodeLength => 'يجب أن يحتوي الرمز على 6 أرقام';

  @override
  String get resetCodeDigitsOnly => 'يجب أن يحتوي الرمز على أرقام فقط';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get confirmPasswordRequired => 'تأكيد كلمة المرور مطلوب';

  @override
  String get passwordsDoNotMatch => 'كلمات المرور غير متطابقة';

  @override
  String get codeSentToEmail => 'تم إرسال الرمز إلى بريدك الإلكتروني';

  @override
  String get errorSendingCode => 'خطأ في إرسال الرمز';

  @override
  String get passwordResetSuccess => 'تم إعادة تعيين كلمة المرور بنجاح';

  @override
  String get errorResettingPassword => 'خطأ في إعادة تعيين كلمة المرور';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get order => 'طلب';

  @override
  String get tickets => 'تذاكر';

  @override
  String get noOrdersFound => 'لم يتم العثور على طلبات';

  @override
  String get noOrdersForThisEvent => 'لم تقم بإجراء أي طلبات لهذه المباراة بعد.';

  @override
  String get ordersFor => 'طلبات لـ';

  @override
  String get myOrders => 'طلباتي';

  @override
  String get endedOn => 'انتهى في';

  @override
  String get ticketPlural => 'فئة/فئات';

  @override
  String get forYou => 'لك';

  @override
  String get transfer => 'تحويل';

  @override
  String get transferPending => 'تحويل قيد الانتظار';

  @override
  String get transferAccepted => 'تم قبول التحويل';

  @override
  String get transferRejected => 'تم رفض التحويل';

  @override
  String get transferred => 'تم التحويل';

  @override
  String get registerTitle => 'تسجيل';

  @override
  String get emailAddress => 'عنوان البريد الإلكتروني';

  @override
  String get firstName => 'الإسم الشخصي';

  @override
  String get lastName => 'الإسم العائلي';

  @override
  String get password => 'كلمة المرور';

  @override
  String get registerButton => 'تسجيل';

  @override
  String get registrationError => 'خطأ في التسجيل';

  @override
  String get registrationSuccess => 'تم التسجيل بنجاح!';

  @override
  String get verifyEmailMessage => 'يرجى التحقق من بريدك الإلكتروني لتفعيل حسابك قبل تسجيل الدخول.';

  @override
  String get registrationErrorGeneric => 'حدث خطأ أثناء التسجيل.';

  @override
  String get internetConnectionError => 'مشكلة في اتصال الإنترنت. يرجى التحقق من اتصالك.';

  @override
  String get loginToAccount => 'سجل الدخول إلى حسابك';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get guestAccess => 'الدخول كزائر';

  @override
  String get noAccount => 'ليس لديك حساب؟ ';

  @override
  String get signUp => 'سجل الآن';

  @override
  String get loginError => 'خطأ في تسجيل الدخول';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get invalidServerResponse => 'رد غير صالح من الخادم';

  @override
  String get incorrectCredentials => 'بيانات الدخول غير صحيحة';

  @override
  String get details => 'تفاصيل';

  @override
  String get cannotOpenWebsite => 'تعذر فتح الموقع الإلكتروني';

  @override
  String get productNotFound => 'المنتج غير موجود';

  @override
  String get failedToLoadProductDetails => 'فشل تحميل تفاصيل المنتج';

  @override
  String get noDescriptionAvailable => 'لا يوجد وصف متاح';

  @override
  String get categories => 'الفئات';

  @override
  String get manOfTheMatch => 'رجل المباراة';

  @override
  String get voteManOfTheMatch => 'التصويت لرجل المباراة';

  @override
  String get errorLoadingData => 'خطأ في تحميل البيانات';

  @override
  String get failedToLoadEventDetails => 'فشل تحميل تفاصيل المباراة';

  @override
  String get failedToLoadPlayers => 'فشل تحميل بيانات اللاعبين';

  @override
  String get loginRequiredToVote => 'يجب تسجيل الدخول للتصويت';

  @override
  String get failedToSubmitVote => 'فشل إرسال التصويت';

  @override
  String get errorSubmittingVote => 'خطأ في إرسال التصويت';

  @override
  String get alreadyVotedForEvent => 'لقد قمت بالفعل بإرسال تصويت لهذه المباراة';

  @override
  String get alreadySelectedPlayer => 'لقد قمت بالفعل باختيار لاعب';

  @override
  String get confirmVote => 'تأكيد تصويتك';

  @override
  String get voteFor => 'هل تريد التصويت لـ';

  @override
  String get voteConfirmationMessage => 'بتأكيدك، سيتم إرسال تصويتك فوراً ولن يمكن تعديله.';

  @override
  String get confirmAndSubmit => 'تأكيد وإرسال';

  @override
  String get addCommentOptional => 'أضف تعليقاً (اختياري)';

  @override
  String get yourComment => 'تعليقك...';

  @override
  String get skip => 'تخطي';

  @override
  String get votedForPlayer => 'تم التصويت';

  @override
  String get voted => 'تم التصويت';

  @override
  String get thankYouForVote => 'شكراً لتصويتك!';

  @override
  String get youVotedFor => 'لقد صوتت لـ';

  @override
  String get unknown => 'غير معروف';

  @override
  String get unknownPlayer => 'لاعب غير معروف';

  @override
  String get nationality => 'الجنسية';

  @override
  String get age => 'العمر';

  @override
  String get notAvailable => 'غير متوفر';

  @override
  String get yearsOld => 'سنة';

  @override
  String get votes => 'تصويتات';

  @override
  String get loginToVote => 'سجل الدخول للتصويت';

  @override
  String get eventFinishedVotesClosed => 'انتهت المباراة - التصويت مغلق';

  @override
  String get alreadyVotedForEventMessage => 'لقد قمت بالفعل بإرسال تصويت لهذه المباراة. شكراً لمشاركتك!';

  @override
  String get onlyOneVoteAllowed => 'يمكنك التصويت للاعب واحد فقط.';

  @override
  String get substitutes => 'البدلاء';

  @override
  String get players => 'لاعبين';

  @override
  String get number => 'رقم';

  @override
  String get youVoted => 'لقد صوتت';

  @override
  String get seeSubstitutes => 'عرض البدلاء';

  @override
  String get alreadyVotedMessage => 'لقد قمت بالفعل بإرسال تصويت لهذه المباراة. شكراً لمشاركتك!';

  @override
  String get loginToVoteMessage => 'سجل الدخول للتصويت للاعبك المفضل';

  @override
  String get manOfTheMatchUnavailable => 'رجل المباراة غير متاح';

  @override
  String get manOfTheMatchUnavailableMessage => 'البيانات غير متاحة لهذه المباراة';

  @override
  String get infoTapPlayer => 'انقر على لاعب لرؤية تفاصيله';

  @override
  String get infoVoteFavorite => 'صوت للاعبك المفضل (تصويت واحد فقط)';

  @override
  String get infoAddComment => 'أضف تعليقاً (اختياري)';

  @override
  String get infoTopThree => 'أفضل 3 لاعبين على منصة التتويج';

  @override
  String get infoSingleVote => 'تصويت واحد نهائي';

  @override
  String get infoVotingOpen => 'التصويت مفتوح حتى نهاية المباراة';

  @override
  String get gotIt => 'فهمت';

  @override
  String get ticketPendingAcceptance => 'تذكرة في انتظار القبول';

  @override
  String get noTicketsAvailable => 'لا توجد تذاكر متاحة';

  @override
  String get transferInProgress => 'جاري التحويل...';

  @override
  String get transferredSuccessfullyTo => 'تم التحويل بنجاح إلى';

  @override
  String get transferError => 'خطأ في التحويل';

  @override
  String get enterRecipientEmail => 'يرجى إدخال عنوان البريد الإلكتروني للشخص الذي تريد تحويل تذاكرك إليه';

  @override
  String get emailExample => 'مثال@mail.com';

  @override
  String get enterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح.';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get userNotFoundMessage => 'لم نتمكن من العثور على المستخدم';

  @override
  String get inviteQuestion => 'هل تريد دعوته؟';

  @override
  String get invite => 'دعوة';

  @override
  String get invitationSentSuccess => 'تم إرسال الدعوة بنجاح';

  @override
  String get invitationError => 'خطأ في الدعوة';

  @override
  String get confirmationSend => 'تأكيد الإرسال';

  @override
  String get aboutToSend => 'أنت على وشك إرسال';

  @override
  String get irreversibleAction => 'هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get continueQuestion => 'هل تريد المتابعة؟';

  @override
  String get selected => 'تم التحديد';

  @override
  String get select => 'تحديد';

  @override
  String get transferTickets => 'تحويل التذاكر';

  @override
  String get eventEnded => 'انتهت المباراة';

  @override
  String get qrCodeNotAuthorized => 'الوصول عبر رمز QR غير مسموح لهذه الفئة من التذاكر';

  @override
  String get ticketAlreadyUsed => 'تم استخدام هذه التذكرة بالفعل';

  @override
  String get ticketAlreadyTransferred => 'تم تحويل هذه التذكرة بالفعل';

  @override
  String get usePhysicalTicket => 'يرجى استخدام تذكرتك الفعلية';

  @override
  String get qrCodeWillAppearBeforeMatch => 'سيظهر رمز QR لتذكرتك قبل المباراة';

  @override
  String get qrCodeNotAvailableForCategory => 'رمز QR غير متاح لهذه الفئة من التذاكر';

  @override
  String get receivedTransferPending => 'لقد تلقيت تحويل تذكرة. يرجى القبول أو الرفض.';

  @override
  String get ticketNotTransferable => 'تذكرة غير قابلة للتحويل';

  @override
  String get ticketStatus => 'حالة التذكرة';

  @override
  String get statusNotPrinted => 'غير مطبوعة';

  @override
  String get statusPrinted => 'مطبوعة';

  @override
  String get statusTransferred => 'تم التحويل';

  @override
  String get statusUsed => 'تم الاستخدام';

  @override
  String get statusUnknown => 'غير معروف';

  @override
  String get eventStartsIn => 'تبدأ المباراة خلال:';

  @override
  String get eventOngoing => 'فعالية جارية';

  @override
  String get invalidDate => 'تاريخ غير صالح';

  @override
  String get days => 'أيام';

  @override
  String get hours => 'س';

  @override
  String get min => 'د';

  @override
  String get sec => 'ث';

  @override
  String get at => 'الساعة';

  @override
  String get gate => 'بوابة';

  @override
  String get access => 'مدخل';

  @override
  String get block => 'قطاع';

  @override
  String get seat => 'مقعد';

  @override
  String get category => 'فئة';

  @override
  String get used => 'مستخدم';

  @override
  String get acceptTransfer => 'قبول التحويل';

  @override
  String get rejectTransfer => 'رفض التحويل';

  @override
  String get transferAcceptedSuccess => 'تم قبول التحويل بنجاح';

  @override
  String get acceptTransferError => 'خطأ أثناء القبول';

  @override
  String get rejectTransferError => 'خطأ أثناء الرفض';

  @override
  String get noTicketFound => 'لم يتم العثور على تذكرة';

  @override
  String get loadingError => 'خطأ في التحميل';

  @override
  String get transferredTicketWillAppearAfterAcceptance => 'ستظهر التذكرة المحولة فقط بعد أن يقبلها المستلم';

  @override
  String get acceptingTransfer => 'جاري قبول التحويل...';

  @override
  String get rejectingTransfer => 'جاري رفض التحويل...';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get transferInformation => 'معلومات التحويل';

  @override
  String get from => 'من';

  @override
  String get numberOfTickets => 'عدد التذاكر';

  @override
  String get unknownError => 'خطأ غير معروف';

  @override
  String get transferRejectedSuccess => 'تم رفض التحويل بنجاح';

  @override
  String get pendingTransferReceived => 'لقد تلقيت تحويلاً معلقاً.';

  @override
  String get myTransfers => 'تحويلاتي';

  @override
  String get loadingTransfers => 'جاري تحميل تحويلاتك...';

  @override
  String get userNotConnected => 'المستخدم غير متصل. يرجى إعادة الاتصال.';

  @override
  String get unknownDate => 'تاريخ غير معروف';

  @override
  String get statusPending => 'قيد الانتظار';

  @override
  String get statusAccepted => 'مقبول';

  @override
  String get statusRejected => 'مرفوض';

  @override
  String get noTransfersSent => 'لا توجد تحويلات مرسلة';

  @override
  String get noTransfersSentMessage => 'التذاكر التي قمت بتحويلها ستظهر هنا';

  @override
  String get totalTransfers => 'إجمالي التحويلات';

  @override
  String get accepted => 'مقبولة';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get rejected => 'مرفوضة';

  @override
  String get recipient => 'المستلم';

  @override
  String get winTickets => 'اربح تذاكر';

  @override
  String get noQuizAvailableToday => 'لا يوجد اختبار متاح اليوم';

  @override
  String get unableToLoadQuizzes => 'تعذر تحميل الاختبارات';

  @override
  String get alreadyParticipated => 'لقد شاركت بالفعل';

  @override
  String get alreadyParticipatedMessage => 'لقد شاركت بالفعل في هذا الاختبار.';

  @override
  String get missingInformation => 'معلومات ناقصة';

  @override
  String get loginToSaveScore => 'سجل الدخول لحفظ نتيجتك';

  @override
  String get yourScoreOf => 'نتيجتك هي';

  @override
  String get hasBeenSaved => 'تم حفظها';

  @override
  String get scoreNotSaved => 'لم يتم حفظ نتيجتك';

  @override
  String get easy => 'سهل';

  @override
  String get medium => 'متوسط';

  @override
  String get hard => 'صعب';

  @override
  String get expert => 'خبير';

  @override
  String get veryGood => 'جيد جداً';

  @override
  String get notBad => 'ليس سيئاً';

  @override
  String get studyMore => 'تحتاج إلى مزيد من المراجعة';

  @override
  String get keepGoing => 'واصل التقدم';

  @override
  String get winnersList => 'قائمة الفائزين';

  @override
  String get youParticipatedInQuiz => 'لقد شاركت في الاختبار';

  @override
  String get ticketsWillBeTransferred => 'سنقوم بتحويل التذاكر تلقائياً للفائزين';

  @override
  String get questions => 'أسئلة';

  @override
  String get levels => 'مستويات';

  @override
  String get minutes => 'دقائق';

  @override
  String get secondsPerQuestion => '20 ثانية لكل سؤال';

  @override
  String get questionsToTestYourKnowledge => 'سؤال لاختبار معرفتك';

  @override
  String get sponsor => 'الراعي';

  @override
  String get thisQuizIsSponsoredBy => 'هذا الاختبار برعاية';

  @override
  String get youHaveAlreadyParticipated => 'لقد شاركت بالفعل في هذا الاختبار';

  @override
  String get startQuiz => 'ابدأ الاختبار';

  @override
  String get first => 'الأول';

  @override
  String get second => 'الثاني';

  @override
  String get third => 'الثالث';

  @override
  String get fourth => 'الرابع';

  @override
  String get fifth => 'الخامس';

  @override
  String get th => '';

  @override
  String get place => 'المركز';

  @override
  String get correctAnswer => 'إجابة صحيحة';

  @override
  String get wrongAnswer => 'إجابة خاطئة';

  @override
  String get results => 'النتائج';

  @override
  String get errorLoadingOrders => 'خطأ في تحميل الطلبات';

  @override
  String get failedToLoadOrderDetails => 'فشل تحميل تفاصيل الطلب';

  @override
  String get orderDeletedSuccess => 'تم حذف الطلب بنجاح';

  @override
  String get failedToDeleteOrder => 'فشل حذف الطلب';

  @override
  String get errorDeletingOrder => 'خطأ في حذف الطلب';

  @override
  String get statusNotProcessed => 'غير معالج';

  @override
  String get statusProcessing => 'قيد المعالجة';

  @override
  String get statusProcessed => 'تمت المعالجة';

  @override
  String get statusDelivered => 'تم التوصيل';

  @override
  String get statusCancelled => 'ملغي';

  @override
  String get statusNotPaid => 'غير مدفوع';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get errorLoadingOrderDetails => 'خطأ في تحميل تفاصيل الطلب';

  @override
  String get ordersWillAppearHere => 'ستظهر طلباتك هنا';

  @override
  String get goToStore => 'اذهب إلى المتجر';

  @override
  String get inProgress => 'قيد المعالجة';

  @override
  String get delivered => 'تم التوصيل';

  @override
  String get items => 'عناصر';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get orderDetails => 'تفاصيل الطلب';

  @override
  String get createdOn => 'تم الإنشاء في';

  @override
  String get paidOn => 'تم الدفع في';

  @override
  String get noItemsFound => 'لم يتم العثور على عناصر';

  @override
  String get unknownProduct => 'منتج غير معروف';

  @override
  String get unit => 'وحدة';

  @override
  String get payNow => 'ادفع الآن';

  @override
  String get whatWouldYouLikeToDo => 'ماذا تريد أن تفعل؟';

  @override
  String get chooseAnOptionBelow => 'اختر خياراً أدناه';

  @override
  String get featureComingSoon => 'هذه الميزة ستكون متاحة قريباً.';

  @override
  String get news => 'الأخبار';

  @override
  String get quiz => 'اختبار';

  @override
  String get loginToAccessQuiz => 'يجب تسجيل الدخول للوصول إلى الاختبار.';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من رغبتك في تسجيل الخروج؟';

  @override
  String get paymentSuccess => 'تم الدفع بنجاح';

  @override
  String get paymentSuccessful => 'تم الدفع بنجاح!';

  @override
  String get amount => 'المبلغ';

  @override
  String get paymentType => 'طريقة الدفع';

  @override
  String get viewMyOrders => 'عرض طلباتي';

  @override
  String get continueShoppingMessage => 'واصل تجربتك وقم بزيارة المتجر الرسمي للوداد';

  @override
  String get cmiPayment => 'دفع آمن CMI';

  @override
  String get connectingToPaymentGateway => 'الاتصال ببوابة الدفع...';

  @override
  String get paymentAcceptedMessage => 'تم قبول دفعتك بنجاح.';

  @override
  String get visitStore => 'زيارة المتجر';

  @override
  String get browserInitError => 'خطأ في تهيئة المتصفح';

  @override
  String get browserNotInitialized => 'المتصفح غير مهيأ';

  @override
  String get unexpectedCmiResponse => 'استجابة غير متوقعة من CMI';

  @override
  String get paymentLoadError => 'خطأ في تحميل الدفع';

  @override
  String get initializingBrowser => 'جاري تهيئة المتصفح...';

  @override
  String get paymentConfirmed => 'تم تأكيد الدفع!';

  @override
  String get paymentProcessedSuccess => 'تمت معالجة دفعتك بنجاح';

  @override
  String get orderNumberTitle => 'رقم الطلب';

  @override
  String get orderIdTitle => 'معرف الطلب';

  @override
  String get amountTitle => 'المبلغ';

  @override
  String get paymentDate => 'تاريخ الدفع';

  @override
  String get orderProcessedSuccess => 'تمت معالجة طلب المتجر الخاص بك بنجاح.';

  @override
  String get backToHome => 'العودة إلى الرئيسية';

  @override
  String get byPmg => 'By PMG';

  @override
  String get ticketAlreadyScanned => 'تم التحقق من هذه التذكرة';

  @override
  String get scannedFromOtherDevice => 'تم التحقق من هذه التذكرة عبر جهاز آخر';

  @override
  String get scanDate => 'تاريخ المسح';

  @override
  String get scanDoor => 'بوابة المسح';

  @override
  String get scanDevice => 'الجهاز';

  @override
  String get otherDevice => 'جهاز آخر';

  @override
  String get unknownDoor => 'بوابة غير معروفة';

  @override
  String get shareMyProfile => 'مشاركة ملفي الشخصي';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get scanToGetContact => 'امسح هذا الرمز للحصول على معلومات الاتصال الخاصة بي';

  @override
  String get shareProfile => 'مشاركة';

  @override
  String shareProfileMessage(Object email) {
    return 'مرحبًا، لتحويل التذاكر إليّ، هذا هو ملفي الشخصي على تطبيق Wydad Ticketing : $email';
  }

  @override
  String get whatsappNotInstalled => 'تطبيق WhatsApp غير مثبت على جهازك';

  @override
  String get user => 'مستخدم';

  @override
  String get phone => 'الهاتف';

  @override
  String get scanQRCode => 'مسح رمز QR';

  @override
  String get positionQRCodeInFrame => 'ضع رمز QR في الإطار';

  @override
  String get invalidEmailFormat => 'تنسيق البريد الإلكتروني غير صالح';

  @override
  String get userNotInOrganization => 'هذا المستخدم لا ينتمي إلى مؤسستك';

  @override
  String get errorCheckingEmail => 'خطأ في التحقق من البريد الإلكتروني';

  @override
  String get individualTicketInfo => 'كل تذكرة مخصصة لشخص واحد فقط. يجب على كل من يصطحب طفلًا شراء تذكرة له.';

  @override
  String get confirmTransfer => 'تأكيد التحويل';

  @override
  String get to => 'إلى';

  @override
  String get confirmTransferButton => 'نعم، تحويل';

  @override
  String get confirmTransferQuestion => 'هل أنت متأكد من إجراء هذا التحويل؟';

  @override
  String get day => 'يوم';

  @override
  String get day_plural => 'أيام';

  @override
  String get hour => 'ساعة';

  @override
  String get hour_plural => 'ساعات';

  @override
  String get minute => 'دقيقة';

  @override
  String get minute_plural => 'دقائق';

  @override
  String get justNow => 'الآن';

  @override
  String get emailVerifiedSuccessfully => '✅ تم التحقق من البريد الإلكتروني بنجاح';

  @override
  String get selectForTransfer => 'اختر للتحويل';

  @override
  String get scannedAtBarrier => 'تم التحقق من التذكرة عند الحاجز';

  @override
  String get scannedAtDoor => 'تم التحقق من التذكرة عند الباب';

  @override
  String get updateRequired => 'التحديث مطلوب';

  @override
  String get updateRequiredMessage => ' يرجى تحديث التطبيق إلى أحدث إصدار لعرض تذاكرك.';

  @override
  String get updateNow => 'تحديث الآن';

  @override
  String get alreadyConnected => 'أنت متصل بالفعل على جهاز آخر.';

  @override
  String get alreadyConnectedMessage => 'أنت متصل بالفعل على جهاز آخر.';

  @override
  String get disconnectInstructions => 'لإعادة الاتصال، انتقل إلى الموقع Wydad.ticketing.ma، ثم إلى ملفي -> الأمان -> تسجيل الخروج من جميع الأجهزة.';

  @override
  String get checkBackLater => 'ارجع لاحقًا';

  @override
  String get ongoing => 'جارٍ';

  @override
  String get cartTitle => 'السلة';

  @override
  String get sizeGuide => 'دليل المقاسات';

  @override
  String get deliveryHomeMorocco => 'توصيل إلى المنزل في جميع أنحاء المغرب';

  @override
  String get deliveryAndPayment => 'التوصيل والدفع';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get estimatedDelivery => 'التوصيل المتوقع';

  @override
  String get payWith => 'الدفع بواسطة';

  @override
  String get balance => 'الرصيد';

  @override
  String get bankCard => 'بطاقة بنكية';

  @override
  String get totalInclDelivery => 'المجموع، شامل التوصيل';

  @override
  String get payOrder => 'ادفع الطلب';

  @override
  String get wydadAc => 'WYDAD AC';

  @override
  String get officialTicketing => 'التذاكر الرسمية';

  @override
  String get eventsTitle => 'المبارايات';

  @override
  String get reserveSeats => 'احجز مقعدك واشتراكك';

  @override
  String get reserve => 'احجز';

  @override
  String get wydadPay => 'WYDAD PAY';

  @override
  String get walletTagline => 'اشحن، حوّل، وادفع';

  @override
  String get activate => 'تفعيل';

  @override
  String get balanceLabel => 'الرصيد';

  @override
  String get ticketplace => 'TICKETPLACE';

  @override
  String get ticketplaceSub => 'إعادة البيع بين المشجعين';

  @override
  String get storeSub => 'القمصان والمنتجات الرسمية';

  @override
  String get newsSub => 'كل أخبار النادي وأحداثه';

  @override
  String get fanZone => 'منطقة المشجعين';

  @override
  String get fanZoneSub => 'مسابقات، تصويت، لاعب المباراة';

  @override
  String get chooseStore => 'اختر متجراً';

  @override
  String get chooseStoreSubtitle => 'اختر المتجر الرسمي لنادي الوداد الرياضي';

  @override
  String get kappaSubtitle => 'متجر Kappa الرسمي';

  @override
  String get wacBrand => 'WAC BRAND';

  @override
  String get wacBrandSubtitle => 'wacofficialbrand.com';

  @override
  String get ticketplaceLabel => 'Ticketplace';

  @override
  String get howToTopUpQuestion => 'كيف تريد تعبئة حسابك؟';

  @override
  String currentBalanceFormat(String balance) {
    return 'الرصيد الحالي: $balance درهم';
  }

  @override
  String get bankCardMethod => 'بطاقة بنكية';

  @override
  String get bankCardMethodSubtitle => 'اشحن رصيدك باستخدام بطاقتك البنكية';

  @override
  String get bankTransferMethod => 'تحويل بنكي';

  @override
  String get bankTransferMethodSubtitle => 'اشحن رصيدك عن طريق تحويل بنكي';

  @override
  String get cashAtAgency => 'نقداً في الوكالة';

  @override
  String get cashAgencyMethodSubtitle => 'اشحن رصيدك في إحدى الوكالات';

  @override
  String get topUpMyAccount => 'إعادة شحن حسابي';

  @override
  String get bankTransferTitle => 'تحويل بنكي';

  @override
  String get bankTransferDescription => 'قم بتحويل بنكي إلى حسابك في Wydad Pay.';

  @override
  String get ribCopied => 'تم نسخ المعلومات البنكية';

  @override
  String get copyRib => 'نسخ المعلومات';

  @override
  String get share => 'مشاركة';

  @override
  String get shareComingSoon => 'ميزة المشاركة ستكون متاحة قريباً';

  @override
  String get addBankAccount => 'إضافة حساب بنكي';

  @override
  String get addBankAccountDescription => 'أضف حساباً بنكياً باسمك لإجراء العمليات.';

  @override
  String get accountName => 'اسم الحساب';

  @override
  String get accountNameHint => 'مثال: حسابي البنكي';

  @override
  String ribWithLength(String length) {
    return 'رقم الحساب البنكي ($length رقماً)';
  }

  @override
  String get ribHint => 'أدخل رقم حسابك البنكي';

  @override
  String get associatedPhoneNumber => 'رقم الهاتف المرتبط';

  @override
  String get phoneNumberHint => 'مثال: 0612345678';

  @override
  String get accountNameRequired => 'اسم الحساب مطلوب';

  @override
  String get ribMustContain24Digits => 'يجب أن يتكون رقم الحساب البنكي من 24 رقماً';

  @override
  String get phoneNumberRequired => 'رقم الهاتف مطلوب';

  @override
  String get addFailed => 'تعذرت إضافة الحساب';

  @override
  String get saveBankAccount => 'حفظ هذا الحساب';

  @override
  String get deleteAccountConfirmationTitle => 'حذف هذا الحساب؟';

  @override
  String deleteAccountConfirmationMessage(String name) {
    return 'هل أنت متأكد أنك تريد حذف الحساب \"$name\"؟';
  }

  @override
  String get deleteFailed => 'تعذر حذف الحساب';

  @override
  String get noBankAccount => 'لا يوجد حساب بنكي مسجل';

  @override
  String get noBankAccountDescription => 'أضف حساباً بنكياً باسمك لاستقبال التحويلات وإجراء عمليات السحب.';

  @override
  String get myBankAccounts => 'حساباتي البنكية';

  @override
  String get defaultAccountName => 'حسابي';

  @override
  String ribMaskedFormat(String rib) {
    return '•••• $rib';
  }

  @override
  String get myWalletRib => 'معلومات حسابي البنكي في Wydad Pay';

  @override
  String get accountHolder => 'صاحب الحساب';

  @override
  String get defaultAccountHolder => 'صاحب الحساب';

  @override
  String get bank => 'البنك';

  @override
  String get defaultBank => 'البنك';

  @override
  String get transferInfo1 => 'استخدم هذه المعلومات البنكية لتحويل الأموال إلى محفظتك في Wydad Pay.';

  @override
  String get transferInfo2 => 'تحقق من المعلومات البنكية قبل تأكيد التحويل.';

  @override
  String get transferInfo3 => 'تعتمد مدة استلام التحويل على البنك الذي تتعامل معه.';

  @override
  String get walletTransferInvalidPhone => 'رقم الهاتف غير صالح';

  @override
  String get walletTransferMinimumAmount => 'الحد الأدنى للمبلغ هو 10 دراهم';

  @override
  String get walletTransferPinFourDigits => 'يجب أن يتكون رمز PIN من 4 أرقام';

  @override
  String get walletTransferFailed => 'فشل التحويل. يرجى المحاولة مرة أخرى.';

  @override
  String get walletTransferSuccess => 'تم التحويل بنجاح';

  @override
  String get walletTransferTitle => 'تحويل الأموال';

  @override
  String get walletTransferRecipientQuestion => 'إلى من تريد إرسال الأموال؟';

  @override
  String get walletTransferRecipientWalletActive => 'يجب أن يكون لدى المستفيد حساب Wydad Pay نشط.';

  @override
  String get walletTransferPhoneNumber => 'رقم الهاتف';

  @override
  String get walletTransferContinue => 'متابعة';

  @override
  String get walletTransferAmountToSend => 'المبلغ المراد إرساله';

  @override
  String get walletTransferOptionalMessage => 'رسالة اختيارية';

  @override
  String get walletTransferNoteHint => 'أضف رسالة';

  @override
  String get walletTransferYouSend => 'أنت ترسل';

  @override
  String get walletTransferBeneficiary => 'المستفيد';

  @override
  String get walletTransferMessage => 'الرسالة';

  @override
  String get walletTransferEnterPin => 'أدخل رمز PIN الخاص بك';

  @override
  String get walletTransferConfirm => 'تأكيد التحويل';

  @override
  String get walletTransferCreditSent => 'تم إرسال تحويلك بنجاح';

  @override
  String get walletTransferDate => 'التاريخ';

  @override
  String get walletTransferPhone => 'الهاتف';

  @override
  String get walletTransferReference => 'المرجع';

  @override
  String get walletTransferBackToWallet => 'العودة إلى المحفظة';

  @override
  String walletTransferToRecipient(String recipient) {
    return 'تحويل إلى $recipient';
  }

  @override
  String get walletWithdrawMyWydadPayAccount => 'حسابي في Wydad Pay';

  @override
  String get walletWithdrawBankAccount => 'حساب بنكي';

  @override
  String get walletWithdrawNoBankAccount => 'لا يوجد حساب بنكي مسجل';

  @override
  String get walletWithdrawPinFourDigits => 'يجب أن يتكون رمز PIN من 4 أرقام';

  @override
  String get walletWithdrawMinimumAmount => 'الحد الأدنى للمبلغ هو 50 درهماً';

  @override
  String get walletWithdrawInsufficientBalance => 'الرصيد غير كافٍ';

  @override
  String get walletWithdrawTransferFailed => 'فشل التحويل البنكي. يرجى المحاولة مرة أخرى.';

  @override
  String get walletWithdrawDeleteAccountTitle => 'حذف هذا الحساب البنكي؟';

  @override
  String walletWithdrawDeleteAccountMessage(String name) {
    return 'هل أنت متأكد أنك تريد حذف الحساب \"$name\"؟';
  }

  @override
  String get walletWithdrawCancel => 'إلغاء';

  @override
  String get walletWithdrawDelete => 'حذف';

  @override
  String get walletWithdrawDeleteFailed => 'تعذر حذف الحساب';

  @override
  String get walletWithdrawBankTitle => 'السحب إلى حساب بنكي';

  @override
  String get walletWithdrawDestinationAccount => 'الحساب المستلم';

  @override
  String get walletWithdrawAddAnotherAccount => 'إضافة حساب آخر';

  @override
  String get walletWithdrawAmount => 'المبلغ المراد سحبه';

  @override
  String walletWithdrawBalance(String amount) {
    return 'الرصيد: $amount درهم';
  }

  @override
  String get walletWithdrawEstimatedReception => 'موعد الاستلام المتوقع';

  @override
  String get walletWithdrawEnterPin => 'أدخل رمز PIN الخاص بك';

  @override
  String walletWithdrawButton(String amount) {
    return 'سحب $amount درهم';
  }

  @override
  String get walletWithdrawInMyName => 'باسمي';

  @override
  String walletWithdrawRib(String rib) {
    return 'رقم الحساب البنكي: $rib';
  }

  @override
  String get walletWithdrawDefault => 'افتراضي';

  @override
  String get walletWithdrawEmptyAccounts => 'لا توجد حسابات بنكية متاحة';

  @override
  String get walletWithdrawTransferSent => 'تم إرسال طلب السحب الخاص بك';

  @override
  String walletWithdrawToAccount(String name) {
    return 'إلى الحساب $name';
  }

  @override
  String get walletWithdrawStatus => 'الحالة';

  @override
  String get walletWithdrawProcessing => 'قيد المعالجة';

  @override
  String get walletWithdrawDate => 'التاريخ';

  @override
  String get walletWithdrawEstimatedReceptionLabel => 'مدة المعالجة المتوقعة';

  @override
  String get walletWithdrawEstimatedReceptionValue => 'حسب مدة المعالجة لدى البنك';

  @override
  String get walletWithdrawBackToWallet => 'العودة إلى المحفظة';

  @override
  String get walletWithdrawCashTitle => 'السحب نقداً';

  @override
  String get walletWithdrawAmountToWithdraw => 'المبلغ المراد سحبه';

  @override
  String walletWithdrawCashBalance(String balance) {
    return 'الرصيد: $balance درهم';
  }

  @override
  String get walletWithdrawCashDescription => 'اسحب أموالك من أي وكالة Chaabi Cash أو Damane Cash أو Tashilat.';

  @override
  String get walletWithdrawFailed => 'فشلت عملية السحب. يرجى المحاولة مرة أخرى.';

  @override
  String get walletWithdrawConnectionError => 'خطأ في الاتصال. يرجى المحاولة مرة أخرى.';

  @override
  String get walletWithdrawAgencyInstructions => 'قدم هذا الرمز وبطاقة هويتك الوطنية عند الشباك لاستلام أموالك.';

  @override
  String get walletWithdrawGetCode => 'الحصول على رمز السحب';

  @override
  String get walletWithdrawCodeInstructions => 'قدم هذا الرمز وبطاقة هويتك الوطنية عند الشباك لاستلام أموالك.';

  @override
  String get walletWithdrawCodeLabel => 'رمز السحب';

  @override
  String get walletWithdrawAmountLabel => 'المبلغ';

  @override
  String get walletWithdrawBlockedAmountInfo => 'تم حجز المبلغ من رصيدك. إذا لم تسحبه قبل انتهاء صلاحيته، فسيتم إرجاعه إلى رصيدك.';

  @override
  String get walletWithdrawBackToHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String get walletWithdrawChooseMethod => 'اختر طريقة السحب';

  @override
  String walletWithdrawAvailableBalance(String balance) {
    return 'الرصيد المتاح: $balance درهم';
  }

  @override
  String get walletWithdrawBankSubtitle => 'استلام الأموال في حسابك البنكي';

  @override
  String get walletWithdrawCashAgency => 'السحب نقداً';

  @override
  String get walletWithdrawCashSubtitle => 'اسحب أموالك من وكالة شريكة';

  @override
  String get walletWithdrawTitle => 'سحب الأموال';

  @override
  String get quizLoading => 'جارٍ تحميل الاختبار...';

  @override
  String quizQuestionProgress(String current, String total) {
    return 'السؤال $current من $total';
  }

  @override
  String get quizOfTheDay => 'اختبار اليوم';

  @override
  String quizQuestionsAboutClub(String count) {
    return '$count أسئلة حول النادي';
  }

  @override
  String quizQuestionsCount(String count) {
    return '$count أسئلة';
  }

  @override
  String get quizRewards => 'المكافآت';

  @override
  String get quizQuestionsLabel => 'الأسئلة';

  @override
  String get quizPerQuestion => 'لكل سؤال';

  @override
  String get quizDuration => 'المدة';

  @override
  String get quizSeconds => 'ثوانٍ';

  @override
  String quizMinutes(String count) {
    return '$count دقائق';
  }

  @override
  String get quizCorrectAnswerLabel => 'الإجابة الصحيحة';

  @override
  String get quizYourAnswerLabel => 'إجابتك';

  @override
  String get quizAnswerQuickly => 'أجب بسرعة!';

  @override
  String get quizGoodAnswers => 'الإجابات الصحيحة';

  @override
  String quizPoints(String points) {
    return '$points نقطة';
  }

  @override
  String get quizParticipatingInDraw => 'أنت الآن مشارك في السحب على الجوائز';

  @override
  String get quizDefaultReward => 'جائزة الاختبار';

  @override
  String get quizBackHome => 'العودة إلى الصفحة الرئيسية';

  @override
  String quizScoreSaved(String score, String total) {
    return 'تم حفظ نتيجتك: $score/$total';
  }

  @override
  String get quizTomorrowAt => 'الاختبار القادم غداً على الساعة';

  @override
  String quizCorrectAnswerExplanation(String answer) {
    return 'الإجابة الصحيحة هي: $answer';
  }

  @override
  String get myAccount => 'حسابي';

  @override
  String get defaultAccountType => 'حساب';

  @override
  String get namePlaceholder => 'الاسم الكامل';

  @override
  String get verified => 'موثق';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get accountLevel => 'مستوى الحساب';

  @override
  String accountLevelWithValue(String level) {
    return 'المستوى $level';
  }

  @override
  String get accountLimit => 'الحد الأقصى';

  @override
  String get identityVerification => 'التحقق من الهوية';

  @override
  String get kycPhoneVerified => 'الهاتف موثق';

  @override
  String get kycPersonalInfo => 'المعلومات الشخصية';

  @override
  String get kycAddress => 'العنوان';

  @override
  String get kycCin => 'البطاقة الوطنية';

  @override
  String get kycSelfie => 'صورة شخصية';

  @override
  String get changePin => 'تغيير رمز PIN';

  @override
  String get logoutWalletSession => 'تسجيل الخروج من المحفظة';

  @override
  String get walletSessionClosed => 'تم إغلاق جلسة المحفظة';

  @override
  String get addAccountInMyName => 'إضافة حساب باسمي';

  @override
  String get addAccountSubtitle => 'أضف حساباً بنكياً باسمك لإجراء عملياتك بسهولة.';

  @override
  String get accountNameLabel => 'اسم الحساب';

  @override
  String get ribLabel => 'رقم الحساب البنكي (RIB)';

  @override
  String get useWalletPhone => 'استخدام رقم هاتف المحفظة';

  @override
  String get associatedPhoneLabel => 'رقم الهاتف المرتبط';

  @override
  String get phoneHintShort => '6 12 34 56 78';

  @override
  String get ribWarning => 'تحقق جيداً من رقم الحساب البنكي قبل الحفظ. لا يمكن تعديله بعد ذلك.';

  @override
  String get saveThisAccount => 'حفظ هذا الحساب';

  @override
  String get newBankAccount => 'حساب بنكي جديد';

  @override
  String get ribMustBe24Digits => 'يجب أن يتكون رقم الحساب البنكي من 24 رقماً';

  @override
  String get addBeneficiaryFailed => 'تعذرت إضافة الحساب';

  @override
  String get receivePayment => 'استلام دفعة';

  @override
  String get accountManagement => 'إدارة الحساب';

  @override
  String get payBill => 'دفع فاتورة';

  @override
  String get payMerchant => 'الدفع لدى تاجر';

  @override
  String get giftCards => 'بطاقات الهدايا';

  @override
  String get myCards => 'بطاقاتي';

  @override
  String get availableSection => 'متاحة';

  @override
  String get soonSection => 'قريباً';

  @override
  String get soonLabel => 'قريباً';

  @override
  String comingSoonMessage(String label) {
    return '$label قادم قريباً';
  }

  @override
  String get allServices => 'جميع الخدمات';

  @override
  String get mobileRecharge => 'شحن الهاتف';

  @override
  String get topUp => 'إعادة الشحن';

  @override
  String get transferAction => 'تحويل';

  @override
  String get withdraw => 'سحب';

  @override
  String get history => 'السجل';

  @override
  String get myWalletAccounts => 'حسابات محفظتي';

  @override
  String get eachAccountLinkedToPhone => 'كل حساب مرتبط برقم هاتف.';

  @override
  String get phoneMaskPlaceholder => '•••• •••• ••';

  @override
  String accountHolderBalance(String holder, String balance) {
    return '$holder · $balance درهم';
  }

  @override
  String get holder => 'صاحب الحساب';

  @override
  String get balancePlaceholder => '—';

  @override
  String get accountAddSoon => 'إضافة حساب آخر ستكون متاحة قريباً';

  @override
  String get addWalletAccount => 'إضافة حساب محفظة';

  @override
  String get historyTitle => 'السجل';

  @override
  String get today => 'اليوم';

  @override
  String get filterRecharges => 'إعادة الشحن';

  @override
  String get filterSent => 'المرسلة';

  @override
  String get filterReceived => 'المستلمة';

  @override
  String get filterCashOut => 'السحب';

  @override
  String get noTransactions => 'لا توجد عمليات';

  @override
  String get levelLabel => 'المستوى';

  @override
  String get subscriptionComingSoonMessage => 'الاشتراك في Wydad Pay سيصبح متاحاً قريباً. ابقَ على اطلاع!';

  @override
  String get digitalWallet => 'المحفظة الرقمية';

  @override
  String get verifiedBadge => 'موثق';

  @override
  String get availableBalanceLabel => 'الرصيد المتاح';

  @override
  String get moreAction => 'المزيد';

  @override
  String get latestOperations => 'آخر العمليات';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get noOperation => 'لا توجد عمليات';

  @override
  String get subscriptionLabel => 'الاشتراك';

  @override
  String get season2026_27 => 'موسم 2026/27';

  @override
  String get supporterNamePlaceholder => 'اسم المشجع';

  @override
  String get tribuneInfoPlaceholder => 'المدرج • المقعد';

  @override
  String get showQRAccess => 'عرض رمز QR';

  @override
  String get nextMatch => 'المباراة القادمة';

  @override
  String get resellMatch => 'إعادة بيع المباراة';

  @override
  String get subscriptionDetails => 'تفاصيل الاشتراك';

  @override
  String get renewSubscription => 'تجديد الاشتراك';

  @override
  String get amountToDeposit => 'المبلغ المراد إيداعه';

  @override
  String get cashAgencyDescription => 'إيداع نقدي في الوكالة';

  @override
  String get minAmount50 => 'الحد الأدنى للمبلغ هو 50 درهماً';

  @override
  String get operationFailedContactSupport => 'فشلت العملية. يرجى الاتصال بالدعم.';

  @override
  String get connectionErrorRetry => 'خطأ في الاتصال. يرجى المحاولة مرة أخرى.';

  @override
  String get cashAgencyInfo => 'قدم الرمز وبطاقة الهوية في أي وكالة شريكة (Chaabi Cash, Damane Cash, Tashilat) لإتمام الإيداع.';

  @override
  String get getMyDepositCode => 'الحصول على رمز الإيداع';

  @override
  String get presentCodeAndCin => 'قدم هذا الرمز وبطاقة هويتك الوطنية عند الشباك.';

  @override
  String get depositCodeLabel => 'رمز الإيداع';

  @override
  String get amountLabel => 'المبلغ';

  @override
  String get balanceWillBeCredited => 'سيتم إضافة المبلغ إلى رصيدك بعد التحقق من الإيداع.';

  @override
  String get cardsLoadFailed => 'تعذر تحميل البطاقات';

  @override
  String get amountBetween50And1000 => 'يجب أن يكون المبلغ بين 50 و 1000 درهم';

  @override
  String get loadingCardsInProgress => 'جاري تحميل البطاقات...';

  @override
  String get noSavedCard => 'لا توجد بطاقة محفوظة';

  @override
  String get pleaseSelectCard => 'يرجى اختيار بطاقة';

  @override
  String get invalidCvv => 'رمز CVV غير صالح';

  @override
  String get genericErrorContactSupport => 'حدث خطأ. يرجى الاتصال بالدعم.';

  @override
  String get paymentCancelledOrFailed => 'تم إلغاء الدفع أو فشل';

  @override
  String get updatingBalance => 'جاري تحديث الرصيد...';

  @override
  String get rechargeAction => 'إعادة الشحن';

  @override
  String get topUpYourWalletAmount => 'اشحن محفظتك';

  @override
  String get transactionLimitLevel1 => 'الحد الأقصى للمعاملة: 1000 درهم (المستوى 1)';

  @override
  String get totalToPay => 'الإجمالي المستحق';

  @override
  String get loadingCards => 'جاري تحميل البطاقات...';

  @override
  String get retryLoadCards => 'إعادة محاولة تحميل البطاقات';

  @override
  String get noCardRefresh => 'لا توجد بطاقة. اضغط للتحديث';

  @override
  String get paymentCard => 'بطاقة الدفع';

  @override
  String selectCardToPay(String amount) {
    return 'اختر البطاقة لدفع $amount درهم';
  }

  @override
  String get noSavedCards => 'لا توجد بطاقات محفوظة';

  @override
  String get addCardFromProfile => 'أضف بطاقة من ملفك الشخصي';

  @override
  String get refresh => 'تحديث';

  @override
  String get cardDefault => 'بطاقة';

  @override
  String get maskedPanPlaceholder => '•••• •••• •••• ••••';

  @override
  String get confirmationTitle => 'تأكيد الدفع';

  @override
  String get enterCvvPrompt => 'أدخل رمز CVV الخاص ببطاقتك';

  @override
  String get cvvHint => 'CVV';

  @override
  String get rechargeDone => 'تمت إعادة الشحن!';

  @override
  String get rechargeSuccessMessage => 'تمت إعادة شحن محفظتك بنجاح.';

  @override
  String get rechargedAmount => 'المبلغ المشحون';

  @override
  String get newBalance => 'الرصيد الجديد';

  @override
  String get later => 'لاحقاً';

  @override
  String get createYourAccount => 'أنشئ حسابك';

  @override
  String get registerSubtitle => 'انضم إلى مجتمع الوداد واستفد من جميع الميزات';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get phoneVerificationNote => 'سيتم إرسال رمز التحقق إلى هذا الرقم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordMinHint => '6 أحرف على الأقل';

  @override
  String get passwordStrengthHint => 'استخدم الحروف والأرقام والرموز لكلمة مرور قوية';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get acceptTermsText => 'أوافق على الشروط والأحكام';

  @override
  String get acceptTermsRequired => 'يجب الموافقة على الشروط والأحكام';

  @override
  String get createMyAccount => 'إنشاء حسابي';

  @override
  String get alreadyRegistered => 'مسجل بالفعل؟ ';

  @override
  String get loginLink => 'تسجيل الدخول';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للوصول إلى تذاكرك ومحفظتك';

  @override
  String get passwordHintLogin => 'أدخل كلمة المرور';

  @override
  String get noAccountYet => 'ليس لديك حساب؟ ';

  @override
  String get createAccountLink => 'سجل الآن';

  @override
  String get onboardingSlide1Title => 'جميع تذاكرك في مكان واحد';

  @override
  String get onboardingSlide1Text => 'اشترِ، حوّل، وأدر تذاكر مباريات الوداد مباشرة من التطبيق.';

  @override
  String get onboardingSlide2Title => 'Wydad Pay، محفظتك الرقمية';

  @override
  String get onboardingSlide2Text => 'اشحن، حوّل، وادفع بسهولة مع محفظة Wydad Pay الآمنة.';

  @override
  String get onboardingSlide3Title => 'عِش تجربة الوداد';

  @override
  String get onboardingSlide3Text => 'صوّت لرجل المباراة، شارك في الاختبارات، واربح جوائز حصرية.';

  @override
  String get alreadyHaveAccount => 'لدي حساب بالفعل';

  @override
  String get continueWithoutAccount => 'المتابعة بدون حساب';

  @override
  String get mockTicketplace => 'TICKETPLACE';

  @override
  String get mockResale => 'إعادة البيع بين المشجعين';

  @override
  String get mockFrom => 'ابتداءً من';

  @override
  String get mockFanZone => 'منطقة المشجعين';

  @override
  String get mockManOfMatch => 'رجل المباراة';

  @override
  String get mockLiveVote => 'تصويت مباشر';

  @override
  String get mockTicket => 'تذكرة';

  @override
  String get mockPremium => 'بريميوم';

  @override
  String get mockStadium => 'الملعب';

  @override
  String get mockGateSeat => 'البوابة A · المقعد 24';

  @override
  String get mockSubscription => 'اشتراك';

  @override
  String get mockSeason => 'موسم 2026/27';

  @override
  String get mockWydadPay => 'WYDAD PAY';

  @override
  String get mockAvailableBalance => 'الرصيد المتاح';

  @override
  String get mockTopUp => 'إعادة الشحن';

  @override
  String get mockTransfer => 'تحويل';

  @override
  String get mockWithdraw => 'سحب';

  @override
  String get mockMore => 'المزيد';

  @override
  String get mockMatchPlayer => 'رجل المباراة';

  @override
  String get mockLive => 'مباشر';

  @override
  String get mockQuizOfDay => 'اختبار اليوم';

  @override
  String get mockWinTickets => 'اربح تذاكر';

  @override
  String get chooseCategory => 'اختر فئة';

  @override
  String quantityRequestedExceedsStock(String requested, String available) {
    return 'المطلوب: $requested، المتاح: $available';
  }

  @override
  String get productUnavailable => 'المنتج غير متاح';

  @override
  String get maillotsOfficiel => 'القميص الرسمي';

  @override
  String get visaMastercard3ds => 'Visa / Mastercard · 3D Secure';

  @override
  String get wydadPayLabel => 'Wydad Pay';

  @override
  String get stadiumName => 'ملعب محمد الخامس';

  @override
  String get transfersButton => 'التحويلات';

  @override
  String get matchPlaceholder => 'مباراة';

  @override
  String pendingTransferLabel(String count) {
    return 'التحويلات المعلقة ($count)';
  }

  @override
  String get senderPlaceholder => 'مشجع';

  @override
  String receivedTicketFrom(String name) {
    return 'تذكرة مستلمة من $name';
  }

  @override
  String get inPendingLabel => 'قيد الانتظار';

  @override
  String get transferAcceptInfo => 'اقبل التحويل لاستلام التذكرة في حسابك.';

  @override
  String get refuse => 'رفض';

  @override
  String myOrdersSection(String count) {
    return 'طلباتي ($count)';
  }

  @override
  String get paidLabel => 'مدفوع';

  @override
  String get receivedLabel => 'مستلم';

  @override
  String get transferredLabel => 'محوّل';

  @override
  String get walletLabel => 'Wydad Pay';

  @override
  String paidOnPayment(String date, String method) {
    return 'تم الدفع في $date · عبر $method';
  }

  @override
  String get ticketFallback => 'تذكرة';

  @override
  String get validLabel => 'صالح';

  @override
  String ticketNumberLabel(String number) {
    return 'رقم $number';
  }

  @override
  String get billetterie => 'التذاكر';

  @override
  String get maxPerAccount => 'الأقصى لكل حساب';

  @override
  String get available => 'متاح';

  @override
  String get soldOut => 'نفد';

  @override
  String get fewSeatsLeft => 'بقي عدد قليل من المقاعد';

  @override
  String get paymentMethodLabel => 'طريقة الدفع';

  @override
  String get insufficientBalance => 'الرصيد غير كافٍ';

  @override
  String get pinCodeLabel => 'رمز PIN';

  @override
  String get pinCodeHint => 'رمز PIN مكون من 4 أرقام';

  @override
  String get cardBankLabel => 'بطاقة بنكية';

  @override
  String get payByCard => 'الدفع بأمان بالبطاقة';

  @override
  String get pinRequired => 'يرجى إدخال رمز PIN المكون من 4 أرقام';

  @override
  String get genericErrorMsg => 'حدث خطأ. يرجى المحاولة مرة أخرى.';

  @override
  String get processingTitle => 'جاري معالجة الدفع...';

  @override
  String get processingSubtitle => 'يرجى الانتظار لحظة';

  @override
  String get paymentSuccessTitle => 'تم الدفع بنجاح';

  @override
  String get paymentSuccessMessage => 'تمت معالجة دفعتك بنجاح.';

  @override
  String get backToEvents => 'العودة إلى المبارايات';

  @override
  String get myInfoSection => 'معلوماتي';

  @override
  String get passwordSection => 'كلمة المرور';

  @override
  String get supporterWac => 'مشجع الوداد';

  @override
  String get cinHintFull => 'مثال: BK123456';

  @override
  String get newPasswordHintMin => '8 أحرف على الأقل، حرف كبير، حرف صغير، ورقم';

  @override
  String get inProgressSection => 'قيد المعالجة';

  @override
  String get previousSection => 'السابقة';

  @override
  String get myOrdersTitle => 'طلباتي';

  @override
  String get orderLabel => 'طلب';

  @override
  String itemsCount(String count) {
    return '$count عنصر';
  }

  @override
  String get passedOn => 'تم في';

  @override
  String get deliveryExpected => 'التوصيل المتوقع';

  @override
  String get carrier => 'الناقل';

  @override
  String get carrierName => 'Wydad Express';

  @override
  String get deliveredStatus => 'تم التوصيل';

  @override
  String get stepConfirmed => 'مؤكد';

  @override
  String get stepPrepared => 'تم التجهيز';

  @override
  String get stepShipped => 'تم الإرسال';

  @override
  String get stepDelivered => 'تم التوصيل';

  @override
  String get statusLabel => 'الحالة';

  @override
  String get paymentLabel => 'الدفع';

  @override
  String get deliveryInfoSection => 'معلومات التوصيل';

  @override
  String get daysShort => 'ي';

  @override
  String get hoursShort => 'س';

  @override
  String get transferTicketTitle => 'تحويل التذكرة';

  @override
  String get transferTicketPrompt => 'أدخل بريد المستلم';

  @override
  String get errorCustomerId => 'خطأ: معرف العميل مفقود';

  @override
  String get transferDone => 'تم التحويل';

  @override
  String get categoryLabel => 'الفئة';

  @override
  String get ticketDetailTitle => 'تفاصيل التذكرة';

  @override
  String get ticketStatusLabel => 'حالة التذكرة';

  @override
  String get transferTicket => 'تحويل';

  @override
  String get wallet => 'المحفظة';

  @override
  String get referenceLabel => 'المرجع';
}
