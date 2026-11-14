// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get firstNameLabel => 'First Name';

  @override
  String get firstNameRequired => 'First name is required';

  @override
  String get firstNameLettersOnly => 'First name must contain only letters';

  @override
  String get firstNameMinLength => 'First name must be at least 2 characters';

  @override
  String get lastNameLabel => 'Last Name';

  @override
  String get lastNameRequired => 'Last name is required';

  @override
  String get lastNameLettersOnly => 'Last name must contain only letters';

  @override
  String get lastNameMinLength => 'Last name must be at least 2 characters';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Phone number must start with 6 or 7 and contain 9 digits';

  @override
  String get phoneHint => '6 12 34 56 78';

  @override
  String get cinLabel => 'ID Card Number';

  @override
  String get cinMinLength => 'Minimum 5 characters';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get currentPasswordRequired => 'Current password is required to change password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get passwordRequirements => 'Password must contain at least one lowercase letter, one uppercase letter, and one number';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get errorLoadingProfile => 'Error loading profile';

  @override
  String get profileUpdatedSuccess => 'Profile updated successfully';

  @override
  String get updateProfileFailed => 'Failed to update profile';

  @override
  String get errorUpdatingProfile => 'Error updating profile';

  @override
  String get emailCannotBeChanged => 'Email cannot be changed. Contact support for any email address modification.';

  @override
  String get emailCannotBeChangedShort => 'Email cannot be changed';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'English';

  @override
  String get logout => 'Logout';

  @override
  String enterYour(Object label) {
    return 'Enter your $label';
  }

  @override
  String get allCategories => 'All Categories';

  @override
  String get allSizes => 'All Sizes';

  @override
  String get seeMyOrders => 'See my orders';

  @override
  String get store => 'Store';

  @override
  String get storeTitle => 'STORE';

  @override
  String get outOfStock => 'Out of stock';

  @override
  String get addToCart => 'Add to cart';

  @override
  String get viewCart => 'View cart';

  @override
  String get noProductsFound => 'No products found';

  @override
  String get productAddedToCart => 'Product added to cart';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get verifyItemsBeforeContinuing => 'Verify selected items before continuing:';

  @override
  String get cartIsEmpty => 'Your cart is empty';

  @override
  String get size => 'Size';

  @override
  String get sizeLabel => 'Size:';

  @override
  String get quantity => 'Quantity';

  @override
  String get productsTotal => 'Products total';

  @override
  String get modify => 'Modify';

  @override
  String get continueText => 'Continue';

  @override
  String get deliveryInformation => 'Delivery information';

  @override
  String get fullNameHint => 'Your full name';

  @override
  String get fullAddress => 'Full address';

  @override
  String get addressHint => 'Street, City, Postal code...';

  @override
  String get deliveryType => 'Delivery type';

  @override
  String get casablanca => 'Casablanca';

  @override
  String get otherCities => 'Other cities';

  @override
  String get productsSubtotal => 'Products subtotal';

  @override
  String get deliveryFee => 'Delivery fee';

  @override
  String get total => 'Total';

  @override
  String get back => 'Back';

  @override
  String get finalOrderSummary => 'Final order summary';

  @override
  String get orderedItems => 'Ordered items';

  @override
  String get verifyOrderInfo => 'Please verify all information before confirming your order.';

  @override
  String get pay => 'Pay';

  @override
  String get orderConfirmed => 'Order confirmed!';

  @override
  String get orderSuccessMessage => 'Your order has been placed successfully. You will receive a call to confirm delivery.';

  @override
  String get close => 'Close';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get unavailableProducts => 'Unavailable products';

  @override
  String get loginRequired => 'Login required';

  @override
  String get loginToAccess => 'Log in to access this feature.';

  @override
  String get login => 'Login';

  @override
  String get noAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get productDetails => 'Product Details';

  @override
  String get description => 'Description';

  @override
  String get availableSizes => 'Available sizes';

  @override
  String get fullNameRequired => 'Full name *';

  @override
  String get fullNameLettersOnly => 'Full name must contain only letters';

  @override
  String get fullNameMinLength => 'Full name must be at least 2 characters';

  @override
  String get addressRequired => 'Delivery address is required';

  @override
  String get addressMinLength => 'Address must be more detailed (at least 10 characters)';

  @override
  String get errorLoadingProductDetails => 'Error loading product details';

  @override
  String get confirmDelete => 'Confirm deletion';

  @override
  String get confirmRemoveProduct => 'Do you really want to remove this product from the cart?';

  @override
  String get delete => 'Delete';

  @override
  String get productImage => 'Product image';

  @override
  String get totalAmount => 'Total amount';

  @override
  String get fees => 'Fees';

  @override
  String get delivery => 'Delivery';

  @override
  String get selectSize => 'Select size';

  @override
  String get selectQuantity => 'Select quantity';

  @override
  String get price => 'Price';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get orderNumber => 'Order number';

  @override
  String get orderDate => 'Order date';

  @override
  String get orderStatus => 'Order status';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get paymentStatus => 'Payment status';

  @override
  String get trackOrder => 'Track order';

  @override
  String get contactSupport => 'Contact support if you think this is an error.';

  @override
  String get termsAndConditions => 'Terms and conditions';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get aboutUs => 'About us';

  @override
  String get contactUs => 'Contact us';

  @override
  String get faq => 'FAQ';

  @override
  String get help => 'Help';

  @override
  String get settings => 'Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get version => 'Version';

  @override
  String get rateApp => 'Rate app';

  @override
  String get shareApp => 'Share app';

  @override
  String get followUs => 'Follow us';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get retry => 'Try again';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get confirm => 'Confirm';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get done => 'Done';

  @override
  String get submit => 'Submit';

  @override
  String get update => 'Update';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get confirmDeleteAccount => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get deleteAccountWarning => 'Warning: Deleting your account will permanently lose all your data.';

  @override
  String get accountDeletedSuccess => 'Account deleted successfully';

  @override
  String get accountDeletionFailed => 'Account deletion failed';

  @override
  String get sessionExpired => 'Session expired, please login again';

  @override
  String get networkError => 'Network error, please check your internet connection';

  @override
  String get serverError => 'Server error';

  @override
  String get unauthorized => 'Unauthorized, please login';

  @override
  String get forbidden => 'You don\'t have permission to access this resource';

  @override
  String get notFound => 'Resource not found';

  @override
  String get validationError => 'Validation error';

  @override
  String get uploadImage => 'Upload image';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get cameraPermissionRequired => 'Camera permission required';

  @override
  String get galleryPermissionRequired => 'Gallery permission required';

  @override
  String get home => 'Home';

  @override
  String get events => 'Events';

  @override
  String get profile => 'Profile';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get shopUnderMaintenance => 'The shop is currently under maintenance.';

  @override
  String get upcoming => 'Coming';

  @override
  String get past => 'Past';

  @override
  String get all => 'All';

  @override
  String get noEventsAvailable => 'No events available!';

  @override
  String get closedOn => 'Closed on';

  @override
  String get startsOn => 'Starts on';

  @override
  String get closed => 'Closed';

  @override
  String get buy => 'Buy';

  @override
  String get vote => 'Vote';

  @override
  String get myTickets => 'My Tickets';

  @override
  String get ticket => 'Ticket';

  @override
  String get maxPerOrder => 'Max per order:';

  @override
  String get buyTickets => 'Buy Tickets';

  @override
  String get eventNotFound => 'Event not found!';

  @override
  String get pleaseTryAgainLater => 'Please try again later';

  @override
  String get eventClosed => 'Event Closed';

  @override
  String get eventClosedMessage => 'This event is no longer accepting new reservations.';

  @override
  String get availableTickets => 'Available Tickets';

  @override
  String get selectNumberOfTickets => 'Select the number of tickets you want';

  @override
  String get proceedToPayment => 'Proceed to payment';

  @override
  String get personalInformation => 'Personal Information';

  @override
  String get enterPersonalInfoToFinalizeOrder => 'Please enter your information to finalize your order';

  @override
  String get fullNameInvalid => 'Invalid full name (min. 4 letters, at least 2 words, no numbers)';

  @override
  String get cinRequired => 'National ID Card (CIN) *';

  @override
  String get cinHint => 'Ex: BK122456';

  @override
  String get cinInvalid => 'Invalid CIN: must start with 1-2 letters, followed by at least 5 digits';

  @override
  String get orderNumberMissing => 'Error: missing order number';

  @override
  String get orderCreationFailed => 'Order creation failed';

  @override
  String get orderCreationError => 'Error creating order';

  @override
  String get connectionError => 'Connection error. Please try again.';

  @override
  String get categoryRestriction => 'Category Restriction';

  @override
  String get categoryRestrictionMessage => 'You can only purchase one ticket category. Please reset the quantity of your previous ticket to 0 to add this one.';

  @override
  String get event => 'event';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get enterEmailToReceiveCode => 'Enter your email address to receive a reset code.';

  @override
  String get sendCode => 'Send Code';

  @override
  String get enterCodeAndNewPassword => 'Enter the code received by email and your new password.';

  @override
  String get resetCode => 'Reset Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get changeEmail => 'Change email';

  @override
  String get resetCodeInfo => 'The reset code is valid for 1 hour. Make sure to check your inbox and spam folder.';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get resetCodeRequired => 'Reset code is required';

  @override
  String get resetCodeLength => 'The code must contain 6 digits';

  @override
  String get resetCodeDigitsOnly => 'The code must contain only digits';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get confirmPasswordRequired => 'Password confirmation is required';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get codeSentToEmail => 'Code sent to your email';

  @override
  String get errorSendingCode => 'Error sending code';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get errorResettingPassword => 'Error resetting password';

  @override
  String get email => 'email';

  @override
  String get order => 'Order';

  @override
  String get tickets => 'Tickets';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get noOrdersForThisEvent => 'You haven\'t placed any orders for this event yet.';

  @override
  String get ordersFor => 'Orders for';

  @override
  String get myOrders => 'My Orders';

  @override
  String get endedOn => 'Ended on';

  @override
  String get ticketPlural => 'ticket(s)';

  @override
  String get forYou => 'For you';

  @override
  String get transfer => 'Transfer';

  @override
  String get transferPending => 'Transfer pending';

  @override
  String get transferAccepted => 'Transfer accepted';

  @override
  String get transferRejected => 'Transfer rejected';

  @override
  String get transferred => 'Transferred';

  @override
  String get registerTitle => 'Register';

  @override
  String get emailAddress => 'Email address';

  @override
  String get firstName => 'First name';

  @override
  String get lastName => 'Last name';

  @override
  String get password => 'Password';

  @override
  String get registerButton => 'REGISTER';

  @override
  String get registrationError => 'Registration Error';

  @override
  String get registrationSuccess => 'Registration successful!';

  @override
  String get verifyEmailMessage => 'Please check your email to activate your account before logging in.';

  @override
  String get registrationErrorGeneric => 'An error occurred during registration.';

  @override
  String get internetConnectionError => 'Internet connection problem. Please check your connection.';

  @override
  String get loginToAccount => 'Login to your account';

  @override
  String get loginButton => 'LOGIN';

  @override
  String get guestAccess => 'ACCESS AS GUEST';

  @override
  String get noAccount => 'Don\'t have an account? ';

  @override
  String get signUp => 'Sign up';

  @override
  String get loginError => 'Login Error';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get invalidServerResponse => 'Invalid server response';

  @override
  String get incorrectCredentials => 'Incorrect credentials';

  @override
  String get details => 'DETAILS';

  @override
  String get cannotOpenWebsite => 'Unable to open website';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get failedToLoadProductDetails => 'Failed to load product details';

  @override
  String get noDescriptionAvailable => 'No description available';

  @override
  String get categories => 'Categories';

  @override
  String get manOfTheMatch => 'MAN OF THE MATCH';

  @override
  String get voteManOfTheMatch => 'VOTE MAN OF THE MATCH';

  @override
  String get errorLoadingData => 'Error loading data';

  @override
  String get failedToLoadEventDetails => 'Failed to load event details';

  @override
  String get failedToLoadPlayers => 'Failed to load players';

  @override
  String get loginRequiredToVote => 'You need to be logged in to vote';

  @override
  String get failedToSubmitVote => 'Failed to submit vote';

  @override
  String get errorSubmittingVote => 'Error submitting vote';

  @override
  String get alreadyVotedForEvent => 'You have already submitted a vote for this event';

  @override
  String get alreadySelectedPlayer => 'You have already selected a player';

  @override
  String get confirmVote => 'Confirm your vote';

  @override
  String get voteFor => 'Do you want to vote for';

  @override
  String get voteConfirmationMessage => 'By confirming, your vote will be immediately submitted and cannot be modified.';

  @override
  String get confirmAndSubmit => 'Confirm and Submit';

  @override
  String get addCommentOptional => 'Add a comment (optional)';

  @override
  String get yourComment => 'Your comment...';

  @override
  String get skip => 'Skip';

  @override
  String get votedForPlayer => 'Voted';

  @override
  String get voted => 'Voted';

  @override
  String get thankYouForVote => 'Thank you for voting!';

  @override
  String get youVotedFor => 'You voted for';

  @override
  String get unknown => 'Unknown';

  @override
  String get unknownPlayer => 'Unknown player';

  @override
  String get nationality => 'Nationality';

  @override
  String get age => 'Age';

  @override
  String get notAvailable => 'N/A';

  @override
  String get yearsOld => 'years old';

  @override
  String get votes => 'votes';

  @override
  String get loginToVote => 'Log in to vote';

  @override
  String get eventFinishedVotesClosed => 'Event finished - Voting is closed';

  @override
  String get alreadyVotedForEventMessage => 'You have already submitted a vote for this event. Thank you for your participation!';

  @override
  String get onlyOneVoteAllowed => 'You can only vote for one player.';

  @override
  String get substitutes => 'Substitutes';

  @override
  String get players => 'Players';

  @override
  String get number => 'No.';

  @override
  String get youVoted => 'You voted';

  @override
  String get seeSubstitutes => 'SEE SUBSTITUTES';

  @override
  String get alreadyVotedMessage => 'You have already submitted a vote for this event. Thank you for your participation!';

  @override
  String get loginToVoteMessage => 'Log in to vote for your favorite player';

  @override
  String get manOfTheMatchUnavailable => 'Man of the match unavailable';

  @override
  String get manOfTheMatchUnavailableMessage => 'Data is not available for this event';

  @override
  String get infoTapPlayer => 'Tap on a player to see their details';

  @override
  String get infoVoteFavorite => 'Vote for your favorite player (1 vote only)';

  @override
  String get infoAddComment => 'Add a comment (optional)';

  @override
  String get infoTopThree => 'The top 3 players are on the podium';

  @override
  String get infoSingleVote => 'Single and definitive vote';

  @override
  String get infoVotingOpen => 'Voting is open until the end of the match';

  @override
  String get gotIt => 'Got it';

  @override
  String get ticketPendingAcceptance => 'Ticket pending acceptance';

  @override
  String get noTicketsAvailable => 'No tickets available';

  @override
  String get transferInProgress => 'Transfer in progress...';

  @override
  String get transferredSuccessfullyTo => 'transferred successfully to';

  @override
  String get transferError => 'Transfer error';

  @override
  String get enterRecipientEmail => 'Please enter the email address of the person you want to transfer your tickets to';

  @override
  String get emailExample => 'example@mail.com';

  @override
  String get enterValidEmail => 'Please enter a valid email.';

  @override
  String get userNotFound => 'User not found';

  @override
  String get userNotFoundMessage => 'We couldn\'t find the user';

  @override
  String get inviteQuestion => 'Would you like to invite them?';

  @override
  String get invite => 'Invite';

  @override
  String get invitationSentSuccess => 'Invitation sent successfully';

  @override
  String get invitationError => 'Invitation error';

  @override
  String get confirmationSend => 'Confirmation of sending';

  @override
  String get aboutToSend => 'You are about to send';

  @override
  String get irreversibleAction => 'This action is irreversible.';

  @override
  String get continueQuestion => 'Do you want to continue?';

  @override
  String get selected => 'Selected';

  @override
  String get select => 'Select';

  @override
  String get transferTickets => 'TRANSFER TICKETS';

  @override
  String get eventEnded => 'Event Ended';

  @override
  String get qrCodeNotAuthorized => 'QR code access is not authorized for this ticket category';

  @override
  String get ticketAlreadyUsed => 'This ticket has already been used';

  @override
  String get ticketAlreadyTransferred => 'This ticket has already been transferred';

  @override
  String get usePhysicalTicket => 'Please use your physical ticket';

  @override
  String get qrCodeWillAppearBeforeMatch => 'Your ticket QR code will appear before the match';

  @override
  String get qrCodeNotAvailableForCategory => 'QR code is not available for this ticket category';

  @override
  String get receivedTransferPending => 'You have received a ticket transfer. Please accept or decline.';

  @override
  String get ticketNotTransferable => 'Non-transferable ticket';

  @override
  String get ticketStatus => 'Ticket status';

  @override
  String get statusNotPrinted => 'Not printed';

  @override
  String get statusPrinted => 'Printed';

  @override
  String get statusTransferred => 'Transferred';

  @override
  String get statusUsed => 'Already used';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get eventStartsIn => 'Event starts in:';

  @override
  String get eventOngoing => 'Event ongoing';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get days => 'days';

  @override
  String get hours => 'h';

  @override
  String get min => 'min';

  @override
  String get sec => 's';

  @override
  String get at => 'at';

  @override
  String get gate => 'GATE';

  @override
  String get access => 'ACCESS';

  @override
  String get block => 'BLOCK';

  @override
  String get seat => 'SEAT';

  @override
  String get category => 'Category';

  @override
  String get used => 'USED';

  @override
  String get acceptTransfer => 'Accept transfer';

  @override
  String get rejectTransfer => 'Reject transfer';

  @override
  String get transferAcceptedSuccess => 'Transfer accepted successfully';

  @override
  String get acceptTransferError => 'Error during acceptance';

  @override
  String get rejectTransferError => 'Error during rejection';

  @override
  String get noTicketFound => 'No ticket found';

  @override
  String get loadingError => 'Loading error';

  @override
  String get transferredTicketWillAppearAfterAcceptance => 'The transferred ticket will only appear after the recipient has accepted it';

  @override
  String get acceptingTransfer => 'Accepting transfer...';

  @override
  String get rejectingTransfer => 'Rejecting transfer...';

  @override
  String get accept => 'ACCEPT';

  @override
  String get reject => 'REJECT';

  @override
  String get transferInformation => 'Transfer information';

  @override
  String get from => 'From';

  @override
  String get numberOfTickets => 'Number of tickets';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get transferRejectedSuccess => 'Transfer rejected successfully';

  @override
  String get pendingTransferReceived => 'You have received a pending transfer.';

  @override
  String get myTransfers => 'My transfers';

  @override
  String get loadingTransfers => 'Loading your transfers...';

  @override
  String get userNotConnected => 'User not connected. Please reconnect.';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get noTransfersSent => 'No transfers sent';

  @override
  String get noTransfersSentMessage => 'Tickets you have transferred will appear here';

  @override
  String get totalTransfers => 'Total transfers';

  @override
  String get accepted => 'Accepted';

  @override
  String get pending => 'Pending';

  @override
  String get rejected => 'Rejected';

  @override
  String get recipient => 'Recipient';

  @override
  String get winTickets => 'Win Tickets';

  @override
  String get noQuizAvailableToday => 'No quiz available today';

  @override
  String get unableToLoadQuizzes => 'Unable to load quizzes';

  @override
  String get alreadyParticipated => 'You have already participated';

  @override
  String get alreadyParticipatedMessage => 'You have already participated in this quiz.';

  @override
  String get missingInformation => 'Missing information';

  @override
  String get loginToSaveScore => 'Log in to save your score';

  @override
  String get yourScoreOf => 'Your score is';

  @override
  String get hasBeenSaved => 'has been saved';

  @override
  String get scoreNotSaved => 'Your score could not be saved';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get expert => 'Expert';

  @override
  String get veryGood => 'Very good';

  @override
  String get notBad => 'Not bad';

  @override
  String get studyMore => 'Study more';

  @override
  String get keepGoing => 'Keep it up';

  @override
  String get winnersList => 'Winners list';

  @override
  String get youParticipatedInQuiz => 'You participated in the quiz';

  @override
  String get ticketsWillBeTransferred => 'We will automatically transfer tickets to rewarded participants';

  @override
  String get questions => 'Questions';

  @override
  String get levels => 'Levels';

  @override
  String get minutes => 'Minutes';

  @override
  String get secondsPerQuestion => '20 sec per question';

  @override
  String get questionsToTestYourKnowledge => 'questions to test your knowledge';

  @override
  String get sponsor => 'Sponsor';

  @override
  String get thisQuizIsSponsoredBy => 'This quiz is sponsored by';

  @override
  String get youHaveAlreadyParticipated => 'You have already participated in this quiz';

  @override
  String get startQuiz => 'Start quiz';

  @override
  String get first => '1st';

  @override
  String get second => '2nd';

  @override
  String get third => '3rd';

  @override
  String get fourth => '4th';

  @override
  String get fifth => '5th';

  @override
  String get th => 'th';

  @override
  String get place => 'place';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get wrongAnswer => 'Wrong answer';

  @override
  String get results => 'RESULTS';

  @override
  String get errorLoadingOrders => 'Error loading orders';

  @override
  String get failedToLoadOrderDetails => 'Failed to load order details';

  @override
  String get orderDeletedSuccess => 'Order deleted successfully';

  @override
  String get failedToDeleteOrder => 'Failed to delete order';

  @override
  String get errorDeletingOrder => 'Error deleting order';

  @override
  String get statusNotProcessed => 'Not processed';

  @override
  String get statusProcessing => 'Processing';

  @override
  String get statusProcessed => 'Processed';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get statusNotPaid => 'Not paid';

  @override
  String get statusPaid => 'Paid';

  @override
  String get errorLoadingOrderDetails => 'Error loading order details';

  @override
  String get ordersWillAppearHere => 'Your orders will appear here';

  @override
  String get goToStore => 'Go to store';

  @override
  String get inProgress => 'In progress';

  @override
  String get delivered => 'Delivered';

  @override
  String get items => 'items';

  @override
  String get viewDetails => 'View details';

  @override
  String get orderDetails => 'Order details';

  @override
  String get createdOn => 'Created on';

  @override
  String get paidOn => 'Paid on';

  @override
  String get noItemsFound => 'No items found';

  @override
  String get unknownProduct => 'Unknown product';

  @override
  String get unit => 'unit';

  @override
  String get payNow => 'Pay now';

  @override
  String get whatWouldYouLikeToDo => 'What would you like to do?';

  @override
  String get chooseAnOptionBelow => 'Choose an option below';

  @override
  String get featureComingSoon => 'This feature will be available soon.';

  @override
  String get news => 'News';

  @override
  String get quiz => 'Quiz';

  @override
  String get loginToAccessQuiz => 'You need to be logged in to access the quiz.';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get paymentSuccess => 'Payment Successful';

  @override
  String get paymentSuccessful => 'Payment Successful!';

  @override
  String get amount => 'Amount';

  @override
  String get paymentType => 'Payment type';

  @override
  String get viewMyOrders => 'View my orders';

  @override
  String get continueShoppingMessage => 'Continue your experience and visit the official WAC store';

  @override
  String get cmiPayment => 'CMI Secure Payment';

  @override
  String get connectingToPaymentGateway => 'Connecting to payment gateway...';

  @override
  String get paymentAcceptedMessage => 'Your payment has been successfully accepted.';

  @override
  String get visitStore => 'Visit the Store';

  @override
  String get browserInitError => 'Browser initialization error';

  @override
  String get browserNotInitialized => 'Browser not initialized';

  @override
  String get unexpectedCmiResponse => 'Unexpected CMI response';

  @override
  String get paymentLoadError => 'Error loading payment';

  @override
  String get initializingBrowser => 'Initializing browser...';

  @override
  String get paymentConfirmed => 'Payment Confirmed!';

  @override
  String get paymentProcessedSuccess => 'Your payment has been processed successfully';

  @override
  String get orderNumberTitle => 'Order number';

  @override
  String get orderIdTitle => 'Order ID';

  @override
  String get amountTitle => 'Amount';

  @override
  String get paymentDate => 'Payment date';

  @override
  String get orderProcessedSuccess => 'Your store order has been processed successfully.';

  @override
  String get backToHome => 'Back to home';

  @override
  String get byPmg => 'By PMG';

  @override
  String get ticketAlreadyScanned => 'Ticket already scanned';

  @override
  String get scannedFromOtherDevice => 'This ticket was scanned from another device. Connect from Your proper Device';

  @override
  String get scanDate => 'Scan date';

  @override
  String get scanDoor => 'Scan door';

  @override
  String get scanDevice => 'Device';

  @override
  String get otherDevice => 'Other device';

  @override
  String get unknownDoor => 'Unknown door';

  @override
  String get shareMyProfile => 'Share my profile';

  @override
  String get myProfile => 'My profile';

  @override
  String get scanToGetContact => 'Scan this code to get my contact information';

  @override
  String get shareProfile => 'Share';

  @override
  String shareProfileMessage(Object email) {
    return 'Hello, to transfer tickets to me, here is my profile on the Wydad Ticketing app : $email';
  }

  @override
  String get whatsappNotInstalled => 'WhatsApp is not installed on your device';

  @override
  String get user => 'User';

  @override
  String get phone => 'Phone';

  @override
  String get scanQRCode => 'Scan QR code';

  @override
  String get positionQRCodeInFrame => 'Position the QR code in the frame';

  @override
  String get invalidEmailFormat => 'Invalid email format';

  @override
  String get userNotInOrganization => 'This user does not belong to your organization';

  @override
  String get errorCheckingEmail => 'Error checking email';

  @override
  String get individualTicketInfo => 'Ticket is individual. Any person accompanying a child must purchase a ticket for them.';

  @override
  String get confirmTransfer => 'Confirm Transfer';

  @override
  String get to => 'to';

  @override
  String get confirmTransferButton => 'Yes, Transfer';

  @override
  String get confirmTransferQuestion => 'Are you sure you want to proceed with this transfer?';

  @override
  String get day => 'day';

  @override
  String get day_plural => 'days';

  @override
  String get hour => 'hour';

  @override
  String get hour_plural => 'hours';

  @override
  String get minute => 'minute';

  @override
  String get minute_plural => 'minutes';

  @override
  String get justNow => 'just now';

  @override
  String get emailVerifiedSuccessfully => '✅ Email verified successfully';

  @override
  String get selectForTransfer => 'Select for transfer';

  @override
  String get scannedAtBarrier => 'Scanned at barrier';

  @override
  String get scannedAtDoor => 'Scanned at door';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateRequiredMessage => 'Please update the app to the latest version to view your tickets.';

  @override
  String get updateNow => 'Update Now';

  @override
  String get alreadyConnected => 'You are already connected on another device.';

  @override
  String get alreadyConnectedMessage => 'You are already connected on another device.';

  @override
  String get disconnectInstructions => 'To reconnect, go to the site Wydad.ticketing.ma, then go to My Profile -> Security -> Log out from all devices.';

  @override
  String get checkBackLater => 'Check back later';

  @override
  String get ongoing => 'Ongoing';

  @override
  String get cartTitle => 'Cart';

  @override
  String get sizeGuide => 'Size guide';

  @override
  String get deliveryHomeMorocco => 'Home delivery across Morocco';

  @override
  String get deliveryAndPayment => 'Delivery and payment';

  @override
  String get deliveryAddress => 'Delivery address';

  @override
  String get estimatedDelivery => 'Estimated delivery';

  @override
  String get payWith => 'Pay with';

  @override
  String get balance => 'Balance';

  @override
  String get bankCard => 'Bank card';

  @override
  String get totalInclDelivery => 'Total, delivery included';

  @override
  String get payOrder => 'Pay order';

  @override
  String get wydadAc => 'WYDAD AC';

  @override
  String get officialTicketing => 'OFFICIAL TICKETING';

  @override
  String get eventsTitle => 'EVENTS';

  @override
  String get reserveSeats => 'Book your seats and subscription';

  @override
  String get reserve => 'Book';

  @override
  String get wydadPay => 'WYDAD PAY';

  @override
  String get walletTagline => 'Top up, transfer, pay';

  @override
  String get activate => 'Activate';

  @override
  String get balanceLabel => 'Balance';

  @override
  String get ticketplace => 'TICKETPLACE';

  @override
  String get ticketplaceSub => 'Resale between fans';

  @override
  String get storeSub => 'Jerseys and official products';

  @override
  String get newsSub => 'All the club\'s news';

  @override
  String get fanZone => 'FAN ZONE';

  @override
  String get fanZoneSub => 'Quiz, votes, man of the match';

  @override
  String get chooseStore => 'Choose a store';

  @override
  String get chooseStoreSubtitle => 'Select the official Wydad AC store';

  @override
  String get kappaSubtitle => 'Official Kappa store';

  @override
  String get wacBrand => 'WAC BRAND';

  @override
  String get wacBrandSubtitle => 'wacofficialbrand.com';

  @override
  String get ticketplaceLabel => 'Ticketplace';

  @override
  String get howToTopUpQuestion => 'How would you like to top up your account?';

  @override
  String currentBalanceFormat(String balance) {
    return 'Current balance: $balance MAD';
  }

  @override
  String get bankCardMethod => 'Bank card';

  @override
  String get bankCardMethodSubtitle => 'Top up using your bank card';

  @override
  String get bankTransferMethod => 'Bank transfer';

  @override
  String get bankTransferMethodSubtitle => 'Top up via bank transfer';

  @override
  String get cashAtAgency => 'Cash at an agency';

  @override
  String get cashAgencyMethodSubtitle => 'Top up at an agency';

  @override
  String get topUpMyAccount => 'Top up my account';

  @override
  String get bankTransferTitle => 'Bank transfer';

  @override
  String get bankTransferDescription => 'Make a bank transfer to your Wydad Pay account.';

  @override
  String get ribCopied => 'Bank details copied';

  @override
  String get copyRib => 'Copy RIB';

  @override
  String get share => 'Share';

  @override
  String get shareComingSoon => 'Sharing feature coming soon';

  @override
  String get addBankAccount => 'Add a bank account';

  @override
  String get addBankAccountDescription => 'Add a bank account in your name to perform transactions.';

  @override
  String get accountName => 'Account name';

  @override
  String get accountNameHint => 'E.g. My bank account';

  @override
  String ribWithLength(String length) {
    return 'Bank account number ($length digits)';
  }

  @override
  String get ribHint => 'Enter your bank account number';

  @override
  String get associatedPhoneNumber => 'Associated phone number';

  @override
  String get phoneNumberHint => 'E.g. 0612345678';

  @override
  String get accountNameRequired => 'Account name is required';

  @override
  String get ribMustContain24Digits => 'The bank account number must contain 24 digits';

  @override
  String get phoneNumberRequired => 'Phone number is required';

  @override
  String get addFailed => 'Failed to add account';

  @override
  String get saveBankAccount => 'Save this account';

  @override
  String get deleteAccountConfirmationTitle => 'Delete this account?';

  @override
  String deleteAccountConfirmationMessage(String name) {
    return 'Are you sure you want to delete the account \"$name\"?';
  }

  @override
  String get deleteFailed => 'Failed to delete account';

  @override
  String get noBankAccount => 'No bank account registered';

  @override
  String get noBankAccountDescription => 'Add an account in your name to receive transfers and make withdrawals.';

  @override
  String get myBankAccounts => 'My bank accounts';

  @override
  String get defaultAccountName => 'My account';

  @override
  String ribMaskedFormat(String rib) {
    return '•••• $rib';
  }

  @override
  String get myWalletRib => 'My Wydad Pay bank details';

  @override
  String get accountHolder => 'Account holder';

  @override
  String get defaultAccountHolder => 'Account holder';

  @override
  String get bank => 'Bank';

  @override
  String get defaultBank => 'Bank';

  @override
  String get transferInfo1 => 'Use these bank details to transfer money to your Wydad Pay wallet.';

  @override
  String get transferInfo2 => 'Check the bank details before confirming your transfer.';

  @override
  String get transferInfo3 => 'The time required to receive the transfer depends on your bank.';

  @override
  String get walletTransferInvalidPhone => 'Invalid phone number';

  @override
  String get walletTransferMinimumAmount => 'The minimum amount is 10 MAD';

  @override
  String get walletTransferPinFourDigits => 'The PIN must contain 4 digits';

  @override
  String get walletTransferFailed => 'Transfer failed. Please try again.';

  @override
  String get walletTransferSuccess => 'Transfer completed successfully';

  @override
  String get walletTransferTitle => 'Money transfer';

  @override
  String get walletTransferRecipientQuestion => 'Who would you like to send money to?';

  @override
  String get walletTransferRecipientWalletActive => 'The recipient must have an active Wydad Pay account.';

  @override
  String get walletTransferPhoneNumber => 'Phone number';

  @override
  String get walletTransferContinue => 'Continue';

  @override
  String get walletTransferAmountToSend => 'Amount to send';

  @override
  String get walletTransferOptionalMessage => 'Optional message';

  @override
  String get walletTransferNoteHint => 'Add a message';

  @override
  String get walletTransferYouSend => 'You send';

  @override
  String get walletTransferBeneficiary => 'Recipient';

  @override
  String get walletTransferMessage => 'Message';

  @override
  String get walletTransferEnterPin => 'Enter your PIN';

  @override
  String get walletTransferConfirm => 'Confirm transfer';

  @override
  String get walletTransferCreditSent => 'Your transfer has been sent successfully';

  @override
  String get walletTransferDate => 'Date';

  @override
  String get walletTransferPhone => 'Phone';

  @override
  String get walletTransferReference => 'Reference';

  @override
  String get walletTransferBackToWallet => 'Back to wallet';

  @override
  String walletTransferToRecipient(String recipient) {
    return 'Transfer to $recipient';
  }

  @override
  String get walletWithdrawMyWydadPayAccount => 'My Wydad Pay account';

  @override
  String get walletWithdrawBankAccount => 'Bank account';

  @override
  String get walletWithdrawNoBankAccount => 'No bank account registered';

  @override
  String get walletWithdrawPinFourDigits => 'The PIN must contain 4 digits';

  @override
  String get walletWithdrawMinimumAmount => 'The minimum amount is 50 MAD';

  @override
  String get walletWithdrawInsufficientBalance => 'Insufficient balance';

  @override
  String get walletWithdrawTransferFailed => 'Bank transfer failed. Please try again.';

  @override
  String get walletWithdrawDeleteAccountTitle => 'Delete this bank account?';

  @override
  String walletWithdrawDeleteAccountMessage(String name) {
    return 'Are you sure you want to delete the account \"$name\"?';
  }

  @override
  String get walletWithdrawCancel => 'Cancel';

  @override
  String get walletWithdrawDelete => 'Delete';

  @override
  String get walletWithdrawDeleteFailed => 'Failed to delete account';

  @override
  String get walletWithdrawBankTitle => 'Withdraw to a bank account';

  @override
  String get walletWithdrawDestinationAccount => 'Destination account';

  @override
  String get walletWithdrawAddAnotherAccount => 'Add another account';

  @override
  String get walletWithdrawAmount => 'Withdrawal amount';

  @override
  String walletWithdrawBalance(String amount) {
    return 'Balance: $amount MAD';
  }

  @override
  String get walletWithdrawEstimatedReception => 'Estimated arrival';

  @override
  String get walletWithdrawEnterPin => 'Enter your PIN';

  @override
  String walletWithdrawButton(String amount) {
    return 'Withdraw $amount MAD';
  }

  @override
  String get walletWithdrawInMyName => 'In my name';

  @override
  String walletWithdrawRib(String rib) {
    return 'Bank details: $rib';
  }

  @override
  String get walletWithdrawDefault => 'Default';

  @override
  String get walletWithdrawEmptyAccounts => 'No bank account available';

  @override
  String get walletWithdrawTransferSent => 'Your withdrawal request has been sent';

  @override
  String walletWithdrawToAccount(String name) {
    return 'To account $name';
  }

  @override
  String get walletWithdrawStatus => 'Status';

  @override
  String get walletWithdrawProcessing => 'Processing';

  @override
  String get walletWithdrawDate => 'Date';

  @override
  String get walletWithdrawEstimatedReceptionLabel => 'Estimated processing time';

  @override
  String get walletWithdrawEstimatedReceptionValue => 'Depending on bank processing times';

  @override
  String get walletWithdrawBackToWallet => 'Back to wallet';

  @override
  String get walletWithdrawCashTitle => 'Cash withdrawal';

  @override
  String get walletWithdrawAmountToWithdraw => 'Amount to withdraw';

  @override
  String walletWithdrawCashBalance(String balance) {
    return 'Balance: $balance MAD';
  }

  @override
  String get walletWithdrawCashDescription => 'Withdraw your money at any Chaabi Cash, Damane Cash or Tashilat agency.';

  @override
  String get walletWithdrawFailed => 'Withdrawal failed. Please try again.';

  @override
  String get walletWithdrawConnectionError => 'Connection error. Please try again.';

  @override
  String get walletWithdrawAgencyInstructions => 'Show this code and your national ID at the counter to collect your money.';

  @override
  String get walletWithdrawGetCode => 'Get my withdrawal code';

  @override
  String get walletWithdrawCodeInstructions => 'Show this code and your national ID at the counter to collect your money.';

  @override
  String get walletWithdrawCodeLabel => 'WITHDRAWAL CODE';

  @override
  String get walletWithdrawAmountLabel => 'Amount';

  @override
  String get walletWithdrawBlockedAmountInfo => 'The amount is reserved from your balance. If you do not withdraw it before it expires, it will be returned to your balance.';

  @override
  String get walletWithdrawBackToHome => 'Back to home';

  @override
  String get walletWithdrawChooseMethod => 'Choose your withdrawal method';

  @override
  String walletWithdrawAvailableBalance(String balance) {
    return 'Available balance: $balance MAD';
  }

  @override
  String get walletWithdrawBankSubtitle => 'Receive the money in your bank account';

  @override
  String get walletWithdrawCashAgency => 'Cash withdrawal';

  @override
  String get walletWithdrawCashSubtitle => 'Withdraw money at a partner agency';

  @override
  String get walletWithdrawTitle => 'Withdraw money';

  @override
  String get quizLoading => 'Loading quiz...';

  @override
  String quizQuestionProgress(String current, String total) {
    return 'Question $current of $total';
  }

  @override
  String get quizOfTheDay => 'Quiz of the day';

  @override
  String quizQuestionsAboutClub(String count) {
    return '$count questions about the club';
  }

  @override
  String quizQuestionsCount(String count) {
    return '$count questions';
  }

  @override
  String get quizRewards => 'Rewards';

  @override
  String get quizQuestionsLabel => 'Questions';

  @override
  String get quizPerQuestion => 'Per question';

  @override
  String get quizDuration => 'Duration';

  @override
  String get quizSeconds => 'seconds';

  @override
  String quizMinutes(String count) {
    return '$count minutes';
  }

  @override
  String get quizCorrectAnswerLabel => 'Correct answer';

  @override
  String get quizYourAnswerLabel => 'Your answer';

  @override
  String get quizAnswerQuickly => 'Answer quickly!';

  @override
  String get quizGoodAnswers => 'Correct answers';

  @override
  String quizPoints(String points) {
    return '$points points';
  }

  @override
  String get quizParticipatingInDraw => 'You are entered into the prize draw';

  @override
  String get quizDefaultReward => 'Quiz reward';

  @override
  String get quizBackHome => 'Back to home';

  @override
  String quizScoreSaved(String score, String total) {
    return 'Your score of $score/$total has been saved';
  }

  @override
  String get quizTomorrowAt => 'Next quiz tomorrow at';

  @override
  String quizCorrectAnswerExplanation(String answer) {
    return 'The correct answer is: $answer';
  }

  @override
  String get myAccount => 'My account';

  @override
  String get defaultAccountType => 'Account';

  @override
  String get namePlaceholder => 'Full name';

  @override
  String get verified => 'Verified';

  @override
  String get accountType => 'Account type';

  @override
  String get accountLevel => 'Account level';

  @override
  String accountLevelWithValue(String level) {
    return 'Level $level';
  }

  @override
  String get accountLimit => 'Limit';

  @override
  String get identityVerification => 'Identity verification';

  @override
  String get kycPhoneVerified => 'Phone verified';

  @override
  String get kycPersonalInfo => 'Personal information';

  @override
  String get kycAddress => 'Address';

  @override
  String get kycCin => 'National ID';

  @override
  String get kycSelfie => 'Selfie';

  @override
  String get changePin => 'Change PIN';

  @override
  String get logoutWalletSession => 'Log out of wallet';

  @override
  String get walletSessionClosed => 'Wallet session closed';

  @override
  String get addAccountInMyName => 'Add an account in my name';

  @override
  String get addAccountSubtitle => 'Add a bank account in your name to perform your transactions easily.';

  @override
  String get accountNameLabel => 'Account name';

  @override
  String get ribLabel => 'Bank account number (RIB)';

  @override
  String get useWalletPhone => 'Use wallet phone number';

  @override
  String get associatedPhoneLabel => 'Associated phone number';

  @override
  String get phoneHintShort => '6 12 34 56 78';

  @override
  String get ribWarning => 'Check your bank account number carefully before saving. It cannot be changed afterwards.';

  @override
  String get saveThisAccount => 'Save this account';

  @override
  String get newBankAccount => 'New bank account';

  @override
  String get ribMustBe24Digits => 'The bank account number must contain 24 digits';

  @override
  String get addBeneficiaryFailed => 'Failed to add account';

  @override
  String get receivePayment => 'Receive payment';

  @override
  String get accountManagement => 'Account management';

  @override
  String get payBill => 'Pay a bill';

  @override
  String get payMerchant => 'Pay a merchant';

  @override
  String get giftCards => 'Gift cards';

  @override
  String get myCards => 'My cards';

  @override
  String get availableSection => 'Available';

  @override
  String get soonSection => 'Coming soon';

  @override
  String get soonLabel => 'SOON';

  @override
  String comingSoonMessage(String label) {
    return '$label coming soon';
  }

  @override
  String get allServices => 'All services';

  @override
  String get mobileRecharge => 'Mobile top-up';

  @override
  String get topUp => 'Top up';

  @override
  String get transferAction => 'Transfer';

  @override
  String get withdraw => 'Withdraw';

  @override
  String get history => 'History';

  @override
  String get myWalletAccounts => 'My wallet accounts';

  @override
  String get eachAccountLinkedToPhone => 'Each account is linked to a phone number.';

  @override
  String get phoneMaskPlaceholder => '•••• •••• ••';

  @override
  String accountHolderBalance(String holder, String balance) {
    return '$holder · $balance MAD';
  }

  @override
  String get holder => 'Account holder';

  @override
  String get balancePlaceholder => '—';

  @override
  String get accountAddSoon => 'Adding another account will be available soon';

  @override
  String get addWalletAccount => 'Add wallet account';

  @override
  String get historyTitle => 'History';

  @override
  String get today => 'Today';

  @override
  String get filterRecharges => 'Top-ups';

  @override
  String get filterSent => 'Sent';

  @override
  String get filterReceived => 'Received';

  @override
  String get filterCashOut => 'Cash out';

  @override
  String get noTransactions => 'No transactions';

  @override
  String get levelLabel => 'Level';

  @override
  String get subscriptionComingSoonMessage => 'Wydad Pay subscription will be available soon. Stay tuned!';

  @override
  String get digitalWallet => 'DIGITAL WALLET';

  @override
  String get verifiedBadge => 'VERIFIED';

  @override
  String get availableBalanceLabel => 'Available balance';

  @override
  String get moreAction => 'More';

  @override
  String get latestOperations => 'Latest operations';

  @override
  String get seeAll => 'See all';

  @override
  String get noOperation => 'No operation';

  @override
  String get subscriptionLabel => 'SUBSCRIPTION';

  @override
  String get season2026_27 => 'Season 2026/27';

  @override
  String get supporterNamePlaceholder => 'Supporter name';

  @override
  String get tribuneInfoPlaceholder => 'Tribune • Seat';

  @override
  String get showQRAccess => 'Show QR access';

  @override
  String get nextMatch => 'Next match';

  @override
  String get resellMatch => 'Resell match';

  @override
  String get subscriptionDetails => 'Subscription details';

  @override
  String get renewSubscription => 'Renew subscription';

  @override
  String get amountToDeposit => 'Amount to deposit';

  @override
  String get cashAgencyDescription => 'Cash deposit at an agency';

  @override
  String get minAmount50 => 'The minimum amount is 50 MAD';

  @override
  String get operationFailedContactSupport => 'Operation failed. Please contact support.';

  @override
  String get connectionErrorRetry => 'Connection error. Please try again.';

  @override
  String get cashAgencyInfo => 'Show the code and your ID at any partner agency (Chaabi Cash, Damane Cash, Tashilat) to complete the deposit.';

  @override
  String get getMyDepositCode => 'Get my deposit code';

  @override
  String get presentCodeAndCin => 'Show this code and your national ID at the counter.';

  @override
  String get depositCodeLabel => 'DEPOSIT CODE';

  @override
  String get amountLabel => 'Amount';

  @override
  String get balanceWillBeCredited => 'The amount will be credited to your balance once the deposit is verified.';

  @override
  String get cardsLoadFailed => 'Failed to load cards';

  @override
  String get amountBetween50And1000 => 'The amount must be between 50 and 1000 MAD';

  @override
  String get loadingCardsInProgress => 'Loading cards...';

  @override
  String get noSavedCard => 'No saved card';

  @override
  String get pleaseSelectCard => 'Please select a card';

  @override
  String get invalidCvv => 'Invalid CVV';

  @override
  String get genericErrorContactSupport => 'An error occurred. Please contact support.';

  @override
  String get paymentCancelledOrFailed => 'Payment cancelled or failed';

  @override
  String get updatingBalance => 'Updating balance...';

  @override
  String get rechargeAction => 'Top up';

  @override
  String get topUpYourWalletAmount => 'Top up your wallet';

  @override
  String get transactionLimitLevel1 => 'Transaction limit: 1000 MAD (Level 1)';

  @override
  String get totalToPay => 'Total to pay';

  @override
  String get loadingCards => 'Loading cards...';

  @override
  String get retryLoadCards => 'Retry loading cards';

  @override
  String get noCardRefresh => 'No card. Tap to refresh';

  @override
  String get paymentCard => 'Payment card';

  @override
  String selectCardToPay(String amount) {
    return 'Select the card to pay $amount MAD';
  }

  @override
  String get noSavedCards => 'No saved cards';

  @override
  String get addCardFromProfile => 'Add a card from your profile';

  @override
  String get refresh => 'Refresh';

  @override
  String get cardDefault => 'Card';

  @override
  String get maskedPanPlaceholder => '•••• •••• •••• ••••';

  @override
  String get confirmationTitle => 'Payment confirmation';

  @override
  String get enterCvvPrompt => 'Enter your card\'s CVV';

  @override
  String get cvvHint => 'CVV';

  @override
  String get rechargeDone => 'Top-up complete!';

  @override
  String get rechargeSuccessMessage => 'Your wallet has been topped up successfully.';

  @override
  String get rechargedAmount => 'Recharged amount';

  @override
  String get newBalance => 'New balance';

  @override
  String get later => 'Later';

  @override
  String get createYourAccount => 'Create your account';

  @override
  String get registerSubtitle => 'Join the Wydad community and access all features';

  @override
  String get emailHint => 'your@email.com';

  @override
  String get phoneVerificationNote => 'A verification code will be sent to this number';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordMinHint => 'Minimum 6 characters';

  @override
  String get passwordStrengthHint => 'Use letters, numbers and symbols for a strong password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get acceptTermsText => 'I accept the terms and conditions';

  @override
  String get acceptTermsRequired => 'You must accept the terms and conditions';

  @override
  String get createMyAccount => 'Create my account';

  @override
  String get alreadyRegistered => 'Already registered? ';

  @override
  String get loginLink => 'Log in';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get loginSubtitle => 'Log in to access your tickets and wallet';

  @override
  String get passwordHintLogin => 'Enter your password';

  @override
  String get noAccountYet => 'Don\'t have an account? ';

  @override
  String get createAccountLink => 'Sign up';

  @override
  String get onboardingSlide1Title => 'All your tickets in one place';

  @override
  String get onboardingSlide1Text => 'Buy, transfer and manage your Wydad match tickets directly from the app.';

  @override
  String get onboardingSlide2Title => 'Wydad Pay, your digital wallet';

  @override
  String get onboardingSlide2Text => 'Top up, transfer and pay easily with your secure Wydad Pay wallet.';

  @override
  String get onboardingSlide3Title => 'Live the Wydad experience';

  @override
  String get onboardingSlide3Text => 'Vote for your man of the match, play quizzes and win exclusive prizes.';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get continueWithoutAccount => 'Continue without account';

  @override
  String get mockTicketplace => 'TICKETPLACE';

  @override
  String get mockResale => 'Resale between fans';

  @override
  String get mockFrom => 'From';

  @override
  String get mockFanZone => 'FAN ZONE';

  @override
  String get mockManOfMatch => 'Man of the match';

  @override
  String get mockLiveVote => 'LIVE VOTE';

  @override
  String get mockTicket => 'TICKET';

  @override
  String get mockPremium => 'PREMIUM';

  @override
  String get mockStadium => 'Stadium';

  @override
  String get mockGateSeat => 'Gate A · Seat 24';

  @override
  String get mockSubscription => 'SUBSCRIPTION';

  @override
  String get mockSeason => 'Season 2026/27';

  @override
  String get mockWydadPay => 'WYDAD PAY';

  @override
  String get mockAvailableBalance => 'Available balance';

  @override
  String get mockTopUp => 'Top up';

  @override
  String get mockTransfer => 'Transfer';

  @override
  String get mockWithdraw => 'Withdraw';

  @override
  String get mockMore => 'More';

  @override
  String get mockMatchPlayer => 'Man of the match';

  @override
  String get mockLive => 'LIVE';

  @override
  String get mockQuizOfDay => 'Quiz of the day';

  @override
  String get mockWinTickets => 'Win tickets';

  @override
  String get chooseCategory => 'Choose a category';

  @override
  String quantityRequestedExceedsStock(String requested, String available) {
    return 'Requested: $requested, available: $available';
  }

  @override
  String get productUnavailable => 'Product unavailable';

  @override
  String get maillotsOfficiel => 'OFFICIAL JERSEY';

  @override
  String get visaMastercard3ds => 'Visa / Mastercard · 3D Secure';

  @override
  String get wydadPayLabel => 'Wydad Pay';

  @override
  String get stadiumName => 'Stade Mohammed V';

  @override
  String get transfersButton => 'Transfers';

  @override
  String get matchPlaceholder => 'Match';

  @override
  String pendingTransferLabel(String count) {
    return 'Pending transfers ($count)';
  }

  @override
  String get senderPlaceholder => 'Supporter';

  @override
  String receivedTicketFrom(String name) {
    return 'Ticket received from $name';
  }

  @override
  String get inPendingLabel => 'Pending';

  @override
  String get transferAcceptInfo => 'Accept the transfer to receive the ticket in your account.';

  @override
  String get refuse => 'Decline';

  @override
  String myOrdersSection(String count) {
    return 'My orders ($count)';
  }

  @override
  String get paidLabel => 'Paid';

  @override
  String get receivedLabel => 'Received';

  @override
  String get transferredLabel => 'Transferred';

  @override
  String get walletLabel => 'Wydad Pay';

  @override
  String paidOnPayment(String date, String method) {
    return 'Paid on $date · via $method';
  }

  @override
  String get ticketFallback => 'Ticket';

  @override
  String get validLabel => 'Valid';

  @override
  String ticketNumberLabel(String number) {
    return 'N°$number';
  }

  @override
  String get billetterie => 'TICKETING';

  @override
  String get maxPerAccount => 'max per account';

  @override
  String get available => 'Available';

  @override
  String get soldOut => 'Sold out';

  @override
  String get fewSeatsLeft => 'Few seats left';

  @override
  String get paymentMethodLabel => 'Payment method';

  @override
  String get insufficientBalance => 'Insufficient balance';

  @override
  String get pinCodeLabel => 'PIN code';

  @override
  String get pinCodeHint => '4-digit PIN';

  @override
  String get cardBankLabel => 'Bank card';

  @override
  String get payByCard => 'Pay securely by card';

  @override
  String get pinRequired => 'Please enter your 4-digit PIN';

  @override
  String get genericErrorMsg => 'An error occurred. Please try again.';

  @override
  String get processingTitle => 'Processing payment...';

  @override
  String get processingSubtitle => 'Please wait a moment';

  @override
  String get paymentSuccessTitle => 'Payment successful';

  @override
  String get paymentSuccessMessage => 'Your payment has been processed successfully.';

  @override
  String get backToEvents => 'Back to events';

  @override
  String get myInfoSection => 'MY INFORMATION';

  @override
  String get passwordSection => 'PASSWORD';

  @override
  String get supporterWac => 'WAC Supporter';

  @override
  String get cinHintFull => 'Ex: BK123456';

  @override
  String get newPasswordHintMin => 'Minimum 8 characters, 1 uppercase, 1 lowercase, 1 number';

  @override
  String get inProgressSection => 'IN PROGRESS';

  @override
  String get previousSection => 'PREVIOUS';

  @override
  String get myOrdersTitle => 'My Orders';

  @override
  String get orderLabel => 'Order';

  @override
  String itemsCount(String count) {
    return '$count item(s)';
  }

  @override
  String get passedOn => 'Placed on';

  @override
  String get deliveryExpected => 'Estimated delivery';

  @override
  String get carrier => 'Carrier';

  @override
  String get carrierName => 'Wydad Express';

  @override
  String get deliveredStatus => 'Delivered';

  @override
  String get stepConfirmed => 'Confirmed';

  @override
  String get stepPrepared => 'Prepared';

  @override
  String get stepShipped => 'Shipped';

  @override
  String get stepDelivered => 'Delivered';

  @override
  String get statusLabel => 'Status';

  @override
  String get paymentLabel => 'Payment';

  @override
  String get deliveryInfoSection => 'DELIVERY INFO';

  @override
  String get daysShort => 'd';

  @override
  String get hoursShort => 'h';

  @override
  String get transferTicketTitle => 'Transfer ticket';

  @override
  String get transferTicketPrompt => 'Enter the recipient\'s email address';

  @override
  String get errorCustomerId => 'Error: customer ID missing';

  @override
  String get transferDone => 'Transfer completed';

  @override
  String get categoryLabel => 'Category';

  @override
  String get ticketDetailTitle => 'Ticket details';

  @override
  String get ticketStatusLabel => 'Ticket status';

  @override
  String get transferTicket => 'Transfer';

  @override
  String get wallet => 'Wallet';

  @override
  String get referenceLabel => 'Reference';
}
