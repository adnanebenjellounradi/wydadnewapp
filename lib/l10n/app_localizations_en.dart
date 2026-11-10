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
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'عربي';

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
  String get retry => 'Retry';

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
  String get noQuizAvailableToday => 'No quiz available for today';

  @override
  String get unableToLoadQuizzes => 'Unable to load quizzes';

  @override
  String get alreadyParticipated => 'Already participated';

  @override
  String get alreadyParticipatedMessage => 'You have already participated in this quiz. Participation is counted only once.';

  @override
  String get missingInformation => 'Missing information';

  @override
  String get loginToSaveScore => 'Please log in so your score can be saved.';

  @override
  String get yourScoreOf => 'Your score of';

  @override
  String get hasBeenSaved => 'has been saved!';

  @override
  String get scoreNotSaved => 'Your score could not be saved. Please try again.';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get expert => '🏆 Expert!';

  @override
  String get veryGood => '🌟 Very good!';

  @override
  String get notBad => '👍 Not bad!';

  @override
  String get studyMore => '📚 Study a bit more';

  @override
  String get keepGoing => '💪 Keep going!';

  @override
  String get winnersList => 'Rewarded participants';

  @override
  String get youParticipatedInQuiz => 'You participated in this quiz';

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
  String get youHaveAlreadyParticipated => 'You have already participated';

  @override
  String get startQuiz => 'START THE QUIZ';

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
  String get correctAnswer => 'Correct answer!';

  @override
  String get wrongAnswer => 'Wrong answer...';

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
}
