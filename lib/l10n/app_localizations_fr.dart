// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get editProfileTitle => 'Modifier le profil';

  @override
  String get firstNameLabel => 'Prénom';

  @override
  String get firstNameRequired => 'Le prénom est requis';

  @override
  String get firstNameLettersOnly => 'Le prénom ne doit contenir que des lettres';

  @override
  String get firstNameMinLength => 'Le prénom doit contenir au moins 2 caractères';

  @override
  String get lastNameLabel => 'Nom';

  @override
  String get lastNameRequired => 'Le nom est requis';

  @override
  String get lastNameLettersOnly => 'Le nom ne doit contenir que des lettres';

  @override
  String get lastNameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String get emailLabel => 'Email';

  @override
  String get phoneLabel => 'Téléphone';

  @override
  String get phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get phoneInvalid => 'Le numéro doit commencer par 6 ou 7 et contenir 9 chiffres';

  @override
  String get phoneHint => '6 12 34 56 78';

  @override
  String get cinLabel => 'CIN';

  @override
  String get cinMinLength => '5 caractères minimum';

  @override
  String get currentPasswordLabel => 'Mot de passe actuel';

  @override
  String get currentPasswordRequired => 'Le mot de passe actuel est requis pour changer le mot de passe';

  @override
  String get newPasswordLabel => 'Nouveau mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get passwordRequirements => 'Le mot de passe doit contenir au moins une lettre minuscule, une majuscule et un chiffre';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get errorLoadingProfile => 'Erreur lors du chargement du profil';

  @override
  String get profileUpdatedSuccess => 'Profil mis à jour avec succès';

  @override
  String get updateProfileFailed => 'Échec de la mise à jour du profil';

  @override
  String get errorUpdatingProfile => 'Erreur lors de la mise à jour du profil';

  @override
  String get emailCannotBeChanged => 'L\'email ne peut pas être modifié. Contactez le support pour toute modification de l\'adresse email.';

  @override
  String get emailCannotBeChangedShort => 'L\'email ne peut pas être modifié';

  @override
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'عربي';

  @override
  String get english => 'English';

  @override
  String get logout => 'Déconnexion';

  @override
  String enterYour(Object label) {
    return 'Entrez votre $label';
  }

  @override
  String get allCategories => 'Toutes les catégories';

  @override
  String get allSizes => 'Toutes les tailles';

  @override
  String get seeMyOrders => 'Voir mes commandes';

  @override
  String get store => 'Boutique';

  @override
  String get storeTitle => 'BOUTIQUE';

  @override
  String get outOfStock => 'Épuisé';

  @override
  String get addToCart => 'Ajouter au panier';

  @override
  String get viewCart => 'Voir le panier';

  @override
  String get noProductsFound => 'Aucun produit trouvé';

  @override
  String get productAddedToCart => 'Produit ajouté au panier';

  @override
  String get orderSummary => 'Récapitulatif de la commande';

  @override
  String get verifyItemsBeforeContinuing => 'Vérifiez les articles sélectionnés avant de continuer :';

  @override
  String get cartIsEmpty => 'Votre panier est vide';

  @override
  String get size => 'Taille';

  @override
  String get sizeLabel => 'Taille :';

  @override
  String get quantity => 'Quantité';

  @override
  String get productsTotal => 'Total produits';

  @override
  String get modify => 'Modifier';

  @override
  String get continueText => 'Continuer';

  @override
  String get deliveryInformation => 'Informations de livraison';

  @override
  String get fullNameHint => 'Votre nom complet';

  @override
  String get fullAddress => 'Adresse complète';

  @override
  String get addressHint => 'N° Rue, Ville, Code postal...';

  @override
  String get deliveryType => 'Type de livraison';

  @override
  String get casablanca => 'Casablanca';

  @override
  String get otherCities => 'Autres villes';

  @override
  String get productsSubtotal => 'Sous-total produits';

  @override
  String get deliveryFee => 'Frais de livraison';

  @override
  String get total => 'Total';

  @override
  String get back => 'Retour';

  @override
  String get finalOrderSummary => 'Résumé final de la commande';

  @override
  String get orderedItems => 'Articles commandés';

  @override
  String get verifyOrderInfo => 'Vérifiez bien toutes les informations avant de confirmer votre commande.';

  @override
  String get pay => 'Payer';

  @override
  String get orderConfirmed => 'Commande confirmée !';

  @override
  String get orderSuccessMessage => 'Votre commande a été passée avec succès. Vous recevrez un appel pour confirmer la livraison.';

  @override
  String get close => 'Fermer';

  @override
  String get error => 'Erreur';

  @override
  String get ok => 'OK';

  @override
  String get unavailableProducts => 'Produits indisponibles';

  @override
  String get loginRequired => 'Connexion requise';

  @override
  String get loginToAccess => 'Connectez-vous pour accéder à cette fonctionnalité.';

  @override
  String get login => 'Connexion';

  @override
  String get noAccountSignUp => 'Pas encore de compte ? S\'inscrire';

  @override
  String get productDetails => 'Détails du produit';

  @override
  String get description => 'Description';

  @override
  String get availableSizes => 'Tailles disponibles';

  @override
  String get fullNameRequired => 'Nom complet *';

  @override
  String get fullNameLettersOnly => 'Le nom complet ne doit contenir que des lettres';

  @override
  String get fullNameMinLength => 'Le nom complet doit contenir au moins 2 caractères';

  @override
  String get addressRequired => 'L\'adresse de livraison est requise';

  @override
  String get addressMinLength => 'L\'adresse doit être plus détaillée (au moins 10 caractères)';

  @override
  String get errorLoadingProductDetails => 'Erreur lors du chargement des détails du produit';

  @override
  String get confirmDelete => 'Confirmer la suppression';

  @override
  String get confirmRemoveProduct => 'Voulez-vous vraiment retirer ce produit du panier ?';

  @override
  String get delete => 'Supprimer';

  @override
  String get productImage => 'Image du produit';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get fees => 'Frais';

  @override
  String get delivery => 'Livraison';

  @override
  String get selectSize => 'Choisir la taille';

  @override
  String get selectQuantity => 'Choisir la quantité';

  @override
  String get price => 'Prix';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get orderNumber => 'Numéro de commande';

  @override
  String get orderDate => 'Date de commande';

  @override
  String get orderStatus => 'Statut de la commande';

  @override
  String get paymentMethod => 'Moyen de paiement';

  @override
  String get paymentStatus => 'Statut du paiement';

  @override
  String get trackOrder => 'Suivre ma commande';

  @override
  String get contactSupport => 'Contactez le support si vous pensez qu\'il s\'agit d\'une erreur.';

  @override
  String get termsAndConditions => 'Conditions générales';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get aboutUs => 'À propos de nous';

  @override
  String get contactUs => 'Contactez-nous';

  @override
  String get faq => 'FAQ';

  @override
  String get help => 'Aide';

  @override
  String get settings => 'Paramètres';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get version => 'Version';

  @override
  String get rateApp => 'Évaluer l\'application';

  @override
  String get shareApp => 'Partager l\'application';

  @override
  String get followUs => 'Suivez-nous';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get loading => 'Chargement...';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get retry => 'Réessayer';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Attention';

  @override
  String get info => 'Information';

  @override
  String get confirm => 'Confirmer';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get done => 'Terminé';

  @override
  String get submit => 'Envoyer';

  @override
  String get update => 'Mettre à jour';

  @override
  String get create => 'Créer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get remove => 'Retirer';

  @override
  String get saveChanges => 'Enregistrer les modifications';

  @override
  String get discardChanges => 'Annuler les modifications';

  @override
  String get confirmDeleteAccount => 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.';

  @override
  String get deleteAccountWarning => 'Attention : La suppression de votre compte entraînera la perte définitive de toutes vos données.';

  @override
  String get accountDeletedSuccess => 'Compte supprimé avec succès';

  @override
  String get accountDeletionFailed => 'Échec de la suppression du compte';

  @override
  String get sessionExpired => 'Session expirée, veuillez vous reconnecter';

  @override
  String get networkError => 'Erreur réseau, vérifiez votre connexion internet';

  @override
  String get serverError => 'Erreur serveur';

  @override
  String get unauthorized => 'Non autorisé, veuillez vous connecter';

  @override
  String get forbidden => 'Vous n\'avez pas la permission d\'accéder à cette ressource';

  @override
  String get notFound => 'Ressource non trouvée';

  @override
  String get validationError => 'Erreur de validation';

  @override
  String get uploadImage => 'Télécharger une image';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get chooseFromGallery => 'Choisir dans la galerie';

  @override
  String get cameraPermissionRequired => 'Permission caméra requise';

  @override
  String get galleryPermissionRequired => 'Permission galerie requise';

  @override
  String get home => 'Accueil';

  @override
  String get events => 'Événements';

  @override
  String get profile => 'Profil';

  @override
  String get comingSoon => 'Bientôt disponible';

  @override
  String get shopUnderMaintenance => 'La boutique est actuellement en maintenance.';

  @override
  String get upcoming => 'À venir';

  @override
  String get past => 'Passés';

  @override
  String get all => 'Tous';

  @override
  String get noEventsAvailable => 'Aucun évènement disponible !';

  @override
  String get closedOn => 'Clôturé le';

  @override
  String get startsOn => 'Débute le';

  @override
  String get closed => 'Clôturé';

  @override
  String get buy => 'Acheter';

  @override
  String get vote => 'Voter';

  @override
  String get myTickets => 'Mes Tickets';

  @override
  String get ticket => 'Ticket';

  @override
  String get maxPerOrder => 'Max par commande :';

  @override
  String get buyTickets => 'Acheter des tickets';

  @override
  String get eventNotFound => 'Événement non trouvé !';

  @override
  String get pleaseTryAgainLater => 'Veuillez réessayer plus tard';

  @override
  String get eventClosed => 'Événement clôturé';

  @override
  String get eventClosedMessage => 'Cet événement n\'accepte plus de nouvelles réservations.';

  @override
  String get availableTickets => 'Tickets disponibles';

  @override
  String get selectNumberOfTickets => 'Sélectionnez le nombre de tickets souhaités';

  @override
  String get proceedToPayment => 'Procéder au paiement';

  @override
  String get personalInformation => 'Informations personnelles';

  @override
  String get enterPersonalInfoToFinalizeOrder => 'Veuillez saisir vos informations pour finaliser votre commande';

  @override
  String get fullNameInvalid => 'Nom complet invalide (min. 4 lettres, au moins 2 mots, pas de chiffres)';

  @override
  String get cinRequired => 'Carte d\'identité nationale (CIN) *';

  @override
  String get cinHint => 'Ex: BK122456';

  @override
  String get cinInvalid => 'CIN invalide : doit commencer par 1-2 lettres, suivies d\'au moins 5 chiffres';

  @override
  String get orderNumberMissing => 'Erreur: numéro de commande manquant';

  @override
  String get orderCreationFailed => 'Échec de création de commande';

  @override
  String get orderCreationError => 'Erreur lors de la création de la commande';

  @override
  String get connectionError => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get categoryRestriction => 'Restriction de catégorie';

  @override
  String get categoryRestrictionMessage => 'Vous ne pouvez acheter qu\'une seule catégorie de billet. Veuillez remettre la quantité de votre billet précédent à 0 pour pouvoir ajouter celui-ci.';

  @override
  String get event => 'évènement';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get enterEmailToReceiveCode => 'Entrez votre adresse email pour recevoir un code de réinitialisation.';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get enterCodeAndNewPassword => 'Entrez le code reçu par email et votre nouveau mot de passe.';

  @override
  String get resetCode => 'Code de réinitialisation';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer mot de passe';

  @override
  String get resetPassword => 'Réinitialiser le mot de passe';

  @override
  String get changeEmail => 'Changer d\'email';

  @override
  String get resetCodeInfo => 'Le code de réinitialisation est valide pendant 1 heure. Assurez-vous de vérifier votre boîte de réception et vos spams.';

  @override
  String get emailRequired => 'L\'email est requis';

  @override
  String get invalidEmail => 'Veuillez entrer un email valide';

  @override
  String get resetCodeRequired => 'Le code de réinitialisation est requis';

  @override
  String get resetCodeLength => 'Le code doit contenir 6 chiffres';

  @override
  String get resetCodeDigitsOnly => 'Le code ne doit contenir que des chiffres';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get confirmPasswordRequired => 'La confirmation du mot de passe est requise';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get codeSentToEmail => 'Code envoyé à votre email';

  @override
  String get errorSendingCode => 'Erreur lors de l\'envoi du code';

  @override
  String get passwordResetSuccess => 'Mot de passe réinitialisé avec succès';

  @override
  String get errorResettingPassword => 'Erreur lors de la réinitialisation';

  @override
  String get email => 'email';

  @override
  String get order => 'Commande';

  @override
  String get tickets => 'Tickets';

  @override
  String get noOrdersFound => 'Aucune commande trouvée';

  @override
  String get noOrdersForThisEvent => 'Vous n\'avez pas encore passé de commande pour cet événement.';

  @override
  String get ordersFor => 'Commandes pour';

  @override
  String get myOrders => 'Mes Commandes';

  @override
  String get endedOn => 'Fini le';

  @override
  String get ticketPlural => 'ticket(s)';

  @override
  String get forYou => 'Pour vous';

  @override
  String get transfer => 'Transférer';

  @override
  String get transferPending => 'Transfert en attente';

  @override
  String get transferAccepted => 'Transfert accepté';

  @override
  String get transferRejected => 'Transfert rejeté';

  @override
  String get transferred => 'Transféré';

  @override
  String get registerTitle => 'Inscription';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get firstName => 'Prénom';

  @override
  String get lastName => 'Nom';

  @override
  String get password => 'Mot de passe';

  @override
  String get registerButton => 'S\'INSCRIRE';

  @override
  String get registrationError => 'Erreur d\'inscription';

  @override
  String get registrationSuccess => 'Inscription réussie !';

  @override
  String get verifyEmailMessage => 'Veuillez vérifier votre email pour activer votre compte avant de vous connecter.';

  @override
  String get registrationErrorGeneric => 'Une erreur s\'est produite lors de l\'inscription.';

  @override
  String get internetConnectionError => 'Problème de connexion internet. Vérifiez votre connexion.';

  @override
  String get loginToAccount => 'Connectez-vous à votre compte';

  @override
  String get loginButton => 'SE CONNECTER';

  @override
  String get guestAccess => 'ACCÉDER À L\'ACCUEIL';

  @override
  String get noAccount => 'Vous n\'avez pas de compte ? ';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get loginError => 'Erreur de connexion';

  @override
  String get loginSuccess => 'Connexion réussie !';

  @override
  String get invalidServerResponse => 'Réponse invalide du serveur';

  @override
  String get incorrectCredentials => 'Identifiants incorrects';

  @override
  String get details => 'DÉTAILS';

  @override
  String get cannotOpenWebsite => 'Impossible d\'ouvrir le site web';

  @override
  String get productNotFound => 'Produit non trouvé';

  @override
  String get failedToLoadProductDetails => 'Échec du chargement des détails du produit';

  @override
  String get noDescriptionAvailable => 'Aucune description disponible';

  @override
  String get categories => 'Catégories';

  @override
  String get manOfTheMatch => 'HOMME DU MATCH';

  @override
  String get voteManOfTheMatch => 'VOTE HOMME DU MATCH';

  @override
  String get errorLoadingData => 'Erreur lors du chargement des données';

  @override
  String get failedToLoadEventDetails => 'Échec du chargement des détails de l\'événement';

  @override
  String get failedToLoadPlayers => 'Échec du chargement des joueurs';

  @override
  String get loginRequiredToVote => 'Vous devez être connecté pour voter';

  @override
  String get failedToSubmitVote => 'Échec de l\'envoi du vote';

  @override
  String get errorSubmittingVote => 'Erreur lors de l\'envoi du vote';

  @override
  String get alreadyVotedForEvent => 'Vous avez déjà soumis un vote pour cet événement';

  @override
  String get alreadySelectedPlayer => 'Vous avez déjà sélectionné un joueur';

  @override
  String get confirmVote => 'Confirmer votre vote';

  @override
  String get voteFor => 'Voulez-vous voter pour';

  @override
  String get voteConfirmationMessage => 'En confirmant, votre vote sera immédiatement soumis et ne pourra pas être modifié.';

  @override
  String get confirmAndSubmit => 'Confirmer et Soumettre';

  @override
  String get addCommentOptional => 'Ajouter un commentaire (optionnel)';

  @override
  String get yourComment => 'Votre commentaire...';

  @override
  String get skip => 'Passer';

  @override
  String get votedForPlayer => 'Voté';

  @override
  String get voted => 'Voté';

  @override
  String get thankYouForVote => 'Merci pour votre vote !';

  @override
  String get youVotedFor => 'Vous avez voté pour';

  @override
  String get unknown => 'Inconnu';

  @override
  String get unknownPlayer => 'Joueur inconnu';

  @override
  String get nationality => 'Nationalité';

  @override
  String get age => 'Âge';

  @override
  String get notAvailable => 'N/A';

  @override
  String get yearsOld => 'ans';

  @override
  String get votes => 'votes';

  @override
  String get loginToVote => 'Connectez-vous pour voter';

  @override
  String get eventFinishedVotesClosed => 'Événement terminé - Les votes sont clos';

  @override
  String get alreadyVotedForEventMessage => 'Vous avez déjà soumis un vote pour cet événement. Merci pour votre participation !';

  @override
  String get onlyOneVoteAllowed => 'Vous ne pouvez voter que pour un seul joueur.';

  @override
  String get substitutes => 'Remplaçants';

  @override
  String get players => 'joueurs';

  @override
  String get number => 'N°';

  @override
  String get youVoted => 'Vous avez voté';

  @override
  String get seeSubstitutes => 'VOIR LES REMPLAÇANTS';

  @override
  String get alreadyVotedMessage => 'Vous avez déjà soumis un vote pour cet événement. Merci pour votre participation !';

  @override
  String get loginToVoteMessage => 'Connectez-vous pour voter pour votre joueur préféré';

  @override
  String get manOfTheMatchUnavailable => 'Homme du match indisponible';

  @override
  String get manOfTheMatchUnavailableMessage => 'Les données ne sont pas disponibles pour cet événement';

  @override
  String get infoTapPlayer => 'Tapez sur un joueur pour voir ses détails';

  @override
  String get infoVoteFavorite => 'Votez pour votre joueur favori (1 seul vote)';

  @override
  String get infoAddComment => 'Ajoutez un commentaire (optionnel)';

  @override
  String get infoTopThree => 'Les 3 meilleurs sont sur le podium';

  @override
  String get infoSingleVote => 'Vote unique et définitif';

  @override
  String get infoVotingOpen => 'Les votes sont ouverts jusqu\'à la fin du match';

  @override
  String get gotIt => 'Compris';

  @override
  String get ticketPendingAcceptance => 'Ticket en attente d\'acceptation';

  @override
  String get noTicketsAvailable => 'Aucun ticket disponible';

  @override
  String get transferInProgress => 'Transfert en cours...';

  @override
  String get transferredSuccessfullyTo => 'transféré(s) avec succès à';

  @override
  String get transferError => 'Erreur lors du transfert';

  @override
  String get enterRecipientEmail => 'Veuillez renseigner l\'adresse mail de la personne à qui vous souhaitez transférer vos tickets';

  @override
  String get emailExample => 'exemple@mail.com';

  @override
  String get enterValidEmail => 'Veuillez saisir un email valide.';

  @override
  String get userNotFound => 'Utilisateur non trouvé';

  @override
  String get userNotFoundMessage => 'Nous n\'avons pas trouvé l\'utilisateur';

  @override
  String get inviteQuestion => 'Voulez-vous l\'inviter ?';

  @override
  String get invite => 'Inviter';

  @override
  String get invitationSentSuccess => 'Invitation envoyée avec succès';

  @override
  String get invitationError => 'Erreur d\'invitation';

  @override
  String get confirmationSend => 'Confirmation d\'envoi';

  @override
  String get aboutToSend => 'Vous êtes sur le point d\'envoyer';

  @override
  String get irreversibleAction => 'Cette action est irréversible.';

  @override
  String get continueQuestion => 'Voulez-vous continuer ?';

  @override
  String get selected => 'Sélectionné';

  @override
  String get select => 'Sélectionner';

  @override
  String get transferTickets => 'TRANSFÉRER DES TICKETS';

  @override
  String get eventEnded => 'Évènement Terminé';

  @override
  String get qrCodeNotAuthorized => 'L\'accès par QR code n\'est pas autorisé pour cette catégorie de ticket';

  @override
  String get ticketAlreadyUsed => 'Ce ticket a déjà été validé à l\'entrée';

  @override
  String get ticketAlreadyTransferred => 'Ce ticket a déjà été transféré';

  @override
  String get usePhysicalTicket => 'Veuillez accéder avec votre ticket physique';

  @override
  String get qrCodeWillAppearBeforeMatch => 'Le QR Code de votre ticket s\'affichera peu avant le match';

  @override
  String get qrCodeNotAvailableForCategory => 'Le QR Code n\'est pas disponible pour cette catégorie de ticket';

  @override
  String get receivedTransferPending => 'Vous avez reçu un transfert de ticket. Veuillez accepter ou refuser.';

  @override
  String get ticketNotTransferable => 'Ticket non transférable';

  @override
  String get ticketStatus => 'Statut ticket';

  @override
  String get statusNotPrinted => 'Non imprimé';

  @override
  String get statusPrinted => 'Imprimé';

  @override
  String get statusTransferred => 'Transféré';

  @override
  String get statusUsed => 'Déjà utilisé';

  @override
  String get statusUnknown => 'Inconnu';

  @override
  String get eventStartsIn => 'L\'évènement démarre dans :';

  @override
  String get eventOngoing => 'Évènement en cours';

  @override
  String get invalidDate => 'Date invalide';

  @override
  String get days => 'jours';

  @override
  String get hours => 'h';

  @override
  String get min => 'min';

  @override
  String get sec => 's';

  @override
  String get at => 'à';

  @override
  String get gate => 'PORTE';

  @override
  String get access => 'ACCÈS';

  @override
  String get block => 'BLOC';

  @override
  String get seat => 'PLACE';

  @override
  String get category => 'Catégorie';

  @override
  String get used => 'USED';

  @override
  String get acceptTransfer => 'Accepter le transfert';

  @override
  String get rejectTransfer => 'Refuser le transfert';

  @override
  String get transferAcceptedSuccess => 'Transfert accepté avec succès';

  @override
  String get acceptTransferError => 'Erreur lors de l\'acceptation';

  @override
  String get rejectTransferError => 'Erreur lors du rejet';

  @override
  String get noTicketFound => 'Aucun ticket trouvé';

  @override
  String get loadingError => 'Erreur de chargement';

  @override
  String get transferredTicketWillAppearAfterAcceptance => 'Le ticket transféré n\'apparaîtra que lorsque le receveur l\'aura accepté';

  @override
  String get acceptingTransfer => 'Acceptation en cours...';

  @override
  String get rejectingTransfer => 'Rejet en cours...';

  @override
  String get accept => 'ACCEPTER';

  @override
  String get reject => 'REJETER';

  @override
  String get transferInformation => 'Informations de transfert';

  @override
  String get from => 'De';

  @override
  String get numberOfTickets => 'Nombre de tickets';

  @override
  String get unknownError => 'Erreur inconnue';

  @override
  String get transferRejectedSuccess => 'Transfert rejeté avec succès';

  @override
  String get pendingTransferReceived => 'Vous avez reçu un transfert en attente.';

  @override
  String get myTransfers => 'Mes transferts';

  @override
  String get loadingTransfers => 'Chargement de vos transferts...';

  @override
  String get userNotConnected => 'Utilisateur non connecté. Veuillez vous reconnecter.';

  @override
  String get unknownDate => 'Date inconnue';

  @override
  String get statusPending => 'En attente';

  @override
  String get statusAccepted => 'Accepté';

  @override
  String get statusRejected => 'Rejeté';

  @override
  String get noTransfersSent => 'Aucun transfert envoyé';

  @override
  String get noTransfersSentMessage => 'Les tickets que vous avez transférés apparaîtront ici';

  @override
  String get totalTransfers => 'Total des transferts';

  @override
  String get accepted => 'Acceptés';

  @override
  String get pending => 'En attente';

  @override
  String get rejected => 'Rejetés';

  @override
  String get recipient => 'Destinataire';

  @override
  String get winTickets => 'Gagner des tickets';

  @override
  String get noQuizAvailableToday => 'Aucun quiz disponible aujourd\'hui';

  @override
  String get unableToLoadQuizzes => 'Impossible de charger les quiz';

  @override
  String get alreadyParticipated => 'Vous avez déjà participé';

  @override
  String get alreadyParticipatedMessage => 'Vous avez déjà participé à ce quiz.';

  @override
  String get missingInformation => 'Informations manquantes';

  @override
  String get loginToSaveScore => 'Connectez-vous pour enregistrer votre score';

  @override
  String get yourScoreOf => 'Votre score est de';

  @override
  String get hasBeenSaved => 'a été enregistré';

  @override
  String get scoreNotSaved => 'Votre score n\'a pas été enregistré';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => 'Expert';

  @override
  String get veryGood => 'Très bien';

  @override
  String get notBad => 'Pas mal';

  @override
  String get studyMore => 'Révisez davantage';

  @override
  String get keepGoing => 'Continuez vos efforts';

  @override
  String get winnersList => 'Liste des gagnants';

  @override
  String get youParticipatedInQuiz => 'Vous avez participé au quiz';

  @override
  String get ticketsWillBeTransferred => 'Nous transfererons automatiquement les tickets aux gagnants';

  @override
  String get questions => 'Questions';

  @override
  String get levels => 'Niveaux';

  @override
  String get minutes => 'Minutes';

  @override
  String get secondsPerQuestion => '20 sec par question';

  @override
  String get questionsToTestYourKnowledge => 'questions pour tester vos connaissances';

  @override
  String get sponsor => 'Sponsor';

  @override
  String get thisQuizIsSponsoredBy => 'Ce quiz est sponsorisé par';

  @override
  String get youHaveAlreadyParticipated => 'Vous avez déjà participé à ce quiz';

  @override
  String get startQuiz => 'Commencer le quiz';

  @override
  String get first => '1er';

  @override
  String get second => '2e';

  @override
  String get third => '3e';

  @override
  String get fourth => '4e';

  @override
  String get fifth => '5e';

  @override
  String get th => 'e';

  @override
  String get place => 'place';

  @override
  String get correctAnswer => 'Bonne réponse';

  @override
  String get wrongAnswer => 'Mauvaise réponse';

  @override
  String get results => 'RÉSULTATS';

  @override
  String get errorLoadingOrders => 'Erreur lors du chargement des commandes';

  @override
  String get failedToLoadOrderDetails => 'Échec du chargement des détails de la commande';

  @override
  String get orderDeletedSuccess => 'Commande supprimée avec succès';

  @override
  String get failedToDeleteOrder => 'Échec de la suppression de la commande';

  @override
  String get errorDeletingOrder => 'Erreur lors de la suppression de la commande';

  @override
  String get statusNotProcessed => 'Non traitée';

  @override
  String get statusProcessing => 'En cours de traitement';

  @override
  String get statusProcessed => 'Traitée';

  @override
  String get statusDelivered => 'Livrée';

  @override
  String get statusCancelled => 'Annulée';

  @override
  String get statusNotPaid => 'Non payé';

  @override
  String get statusPaid => 'Payé';

  @override
  String get errorLoadingOrderDetails => 'Erreur lors du chargement des détails de la commande';

  @override
  String get ordersWillAppearHere => 'Vos commandes apparaîtront ici';

  @override
  String get goToStore => 'Aller à la boutique';

  @override
  String get inProgress => 'En cours';

  @override
  String get delivered => 'Livrées';

  @override
  String get items => 'articles';

  @override
  String get viewDetails => 'Voir détails';

  @override
  String get orderDetails => 'Détails de la commande';

  @override
  String get createdOn => 'Créée le';

  @override
  String get paidOn => 'Payé le';

  @override
  String get noItemsFound => 'Aucun article trouvé';

  @override
  String get unknownProduct => 'Produit inconnu';

  @override
  String get unit => 'unité';

  @override
  String get payNow => 'Payer maintenant';

  @override
  String get whatWouldYouLikeToDo => 'Que souhaitez-vous faire ?';

  @override
  String get chooseAnOptionBelow => 'Choisissez une option ci-dessous';

  @override
  String get featureComingSoon => 'Cette fonctionnalité sera bientôt disponible.';

  @override
  String get news => 'Actualités';

  @override
  String get quiz => 'Quiz';

  @override
  String get loginToAccessQuiz => 'Vous devez être connecté pour accéder au quiz.';

  @override
  String get logoutConfirmation => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get paymentSuccess => 'Paiement Réussi';

  @override
  String get paymentSuccessful => 'Paiement réussi !';

  @override
  String get amount => 'Montant';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get viewMyOrders => 'Voir mes commandes';

  @override
  String get continueShoppingMessage => 'Continuez votre expérience et visitez le store officiel du WAC';

  @override
  String get cmiPayment => 'Paiement Sécurisé CMI';

  @override
  String get connectingToPaymentGateway => 'Connexion à la passerelle de paiement...';

  @override
  String get paymentAcceptedMessage => 'Votre paiement a été accepté avec succès.';

  @override
  String get visitStore => 'Visiter la Boutique';

  @override
  String get browserInitError => 'Erreur d\'initialisation du navigateur';

  @override
  String get browserNotInitialized => 'Navigateur non initialisé';

  @override
  String get unexpectedCmiResponse => 'Réponse inattendue de CMI';

  @override
  String get paymentLoadError => 'Erreur lors du chargement du paiement';

  @override
  String get initializingBrowser => 'Initialisation du navigateur...';

  @override
  String get paymentConfirmed => 'Paiement Confirmé !';

  @override
  String get paymentProcessedSuccess => 'Votre paiement a été traité avec succès';

  @override
  String get orderNumberTitle => 'Numéro de commande';

  @override
  String get orderIdTitle => 'ID de commande';

  @override
  String get amountTitle => 'Montant';

  @override
  String get paymentDate => 'Date de paiement';

  @override
  String get orderProcessedSuccess => 'Votre commande boutique a été traitée avec succès.';

  @override
  String get backToHome => 'Retour à l\'accueil';

  @override
  String get byPmg => 'Par PMG';

  @override
  String get ticketAlreadyScanned => 'Ticket déjà scanné';

  @override
  String get scannedFromOtherDevice => 'Ce ticket a été scanné depuis un autre appareil. veuillez vous connecter avec votre autre appareil';

  @override
  String get scanDate => 'Date de scan';

  @override
  String get scanDoor => 'Porte de scan';

  @override
  String get scanDevice => 'Appareil';

  @override
  String get otherDevice => 'Autre appareil';

  @override
  String get unknownDoor => 'Porte inconnue';

  @override
  String get shareMyProfile => 'Partager mon profil';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get scanToGetContact => 'Scannez ce code pour obtenir mes coordonnées';

  @override
  String get shareProfile => 'Partager';

  @override
  String shareProfileMessage(Object email) {
    return 'Bonjour, pour me transférer des tickets, voici mon profil sur l\'application Wydad Ticketing : $email';
  }

  @override
  String get whatsappNotInstalled => 'WhatsApp n\'est pas installé sur votre appareil';

  @override
  String get user => 'Utilisateur';

  @override
  String get phone => 'Téléphone';

  @override
  String get scanQRCode => 'Scanner un QR code';

  @override
  String get positionQRCodeInFrame => 'Positionnez le QR code dans le cadre';

  @override
  String get invalidEmailFormat => 'Format d\'email invalide';

  @override
  String get userNotInOrganization => 'Cet utilisateur n\'appartient pas à votre organisation';

  @override
  String get errorCheckingEmail => 'Erreur lors de la vérification de l\'email';

  @override
  String get individualTicketInfo => 'Chaque ticket est strictement personnel. Toute personne accompagnée d\'un enfant doit obligatoirement lui acheter un ticket.';

  @override
  String get confirmTransfer => 'Confirmer le transfert';

  @override
  String get to => 'à';

  @override
  String get confirmTransferButton => 'Oui, transférer';

  @override
  String get confirmTransferQuestion => 'Voulez-vous vraiment effectuer ce transfert ?';

  @override
  String get day => 'jour';

  @override
  String get day_plural => 'jours';

  @override
  String get hour => 'heure';

  @override
  String get hour_plural => 'heures';

  @override
  String get minute => 'minute';

  @override
  String get minute_plural => 'minutes';

  @override
  String get justNow => 'à l\'instant';

  @override
  String get emailVerifiedSuccessfully => '✅ Email vérifié avec succès';

  @override
  String get selectForTransfer => 'Sélectionner pour transfert';

  @override
  String get scannedAtBarrier => 'Ticket Scanné au barrage';

  @override
  String get scannedAtDoor => 'Ticket Scanné à la porte';

  @override
  String get updateRequired => 'Mise à jour requise';

  @override
  String get updateRequiredMessage => 'Veuillez installer la dernière version de l\'application pour voir vos tickets.';

  @override
  String get updateNow => 'Mettre à jour maintenant';

  @override
  String get alreadyConnected => 'Vous êtes déjà connecté sur un autre appareil. ';

  @override
  String get alreadyConnectedMessage => 'Vous êtes déjà connecté sur un autre appareil.';

  @override
  String get disconnectInstructions => 'Pour vous reconnecter, redirigez vous sur le site Wydad.ticketing.ma, puis allez sur mon profil -> sécurité -> Me déconnecter de tout les appareils.';

  @override
  String get checkBackLater => 'Revenez plus tard';

  @override
  String get ongoing => 'En cours';

  @override
  String get cartTitle => 'Panier';

  @override
  String get sizeGuide => 'Guide des tailles';

  @override
  String get deliveryHomeMorocco => 'Livraison à domicile partout au Maroc';

  @override
  String get deliveryAndPayment => 'Livraison et paiement';

  @override
  String get deliveryAddress => 'Adresse de livraison';

  @override
  String get estimatedDelivery => 'Livraison estimée';

  @override
  String get payWith => 'Payer avec';

  @override
  String get balance => 'Solde';

  @override
  String get bankCard => 'Carte bancaire';

  @override
  String get totalInclDelivery => 'Total, livraison incluse';

  @override
  String get payOrder => 'Payer la commande';

  @override
  String get wydadAc => 'WYDAD AC';

  @override
  String get officialTicketing => 'BILLETTERIE OFFICIELLE';

  @override
  String get eventsTitle => 'ÉVÉNEMENTS';

  @override
  String get reserveSeats => 'Réservez vos places et votre abonnement';

  @override
  String get reserve => 'Réserver';

  @override
  String get wydadPay => 'WYDAD PAY';

  @override
  String get walletTagline => 'Alimentez, transférez, payez';

  @override
  String get activate => 'Activer';

  @override
  String get balanceLabel => 'Solde';

  @override
  String get ticketplace => 'TICKETPLACE';

  @override
  String get ticketplaceSub => 'Revente entre supporters';

  @override
  String get storeSub => 'Maillots et produits officiels';

  @override
  String get newsSub => 'Suivez les actualités du club';

  @override
  String get fanZone => 'FAN ZONE';

  @override
  String get fanZoneSub => 'Quiz, votes, homme du match';

  @override
  String get chooseStore => 'Choisir une boutique';

  @override
  String get chooseStoreSubtitle => 'Sélectionnez la boutique officielle Wydad AC';

  @override
  String get kappaSubtitle => 'Boutique officielle Kappa';

  @override
  String get wacBrand => 'WAC BRAND';

  @override
  String get wacBrandSubtitle => 'wacofficialbrand.com';

  @override
  String get ticketplaceLabel => 'Ticketplace';

  @override
  String get howToTopUpQuestion => 'Comment souhaitez-vous recharger votre compte ?';

  @override
  String currentBalanceFormat(String balance) {
    return 'Solde actuel : $balance MAD';
  }

  @override
  String get bankCardMethod => 'Carte bancaire';

  @override
  String get bankCardMethodSubtitle => 'Rechargez avec votre carte bancaire';

  @override
  String get bankTransferMethod => 'Virement bancaire';

  @override
  String get bankTransferMethodSubtitle => 'Rechargez par virement bancaire';

  @override
  String get cashAtAgency => 'Espèces en agence';

  @override
  String get cashAgencyMethodSubtitle => 'Rechargez dans une agence';

  @override
  String get topUpMyAccount => 'Recharger mon compte';

  @override
  String get bankTransferTitle => 'Virement bancaire';

  @override
  String get bankTransferDescription => 'Effectuez un virement vers votre compte Wydad Pay.';

  @override
  String get ribCopied => 'RIB copié';

  @override
  String get copyRib => 'Copier le RIB';

  @override
  String get share => 'Partager';

  @override
  String get shareComingSoon => 'Fonctionnalité de partage bientôt disponible';

  @override
  String get addBankAccount => 'Ajouter un compte bancaire';

  @override
  String get addBankAccountDescription => 'Ajoutez un compte bancaire à votre nom pour effectuer des opérations.';

  @override
  String get accountName => 'Nom du compte';

  @override
  String get accountNameHint => 'Ex. : Mon compte bancaire';

  @override
  String ribWithLength(String length) {
    return 'RIB ($length chiffres)';
  }

  @override
  String get ribHint => 'Saisissez votre RIB';

  @override
  String get associatedPhoneNumber => 'Numéro de téléphone associé';

  @override
  String get phoneNumberHint => 'Ex. : 0612345678';

  @override
  String get accountNameRequired => 'Nom du compte requis';

  @override
  String get ribMustContain24Digits => 'Le RIB doit contenir 24 chiffres';

  @override
  String get phoneNumberRequired => 'Numéro de téléphone requis';

  @override
  String get addFailed => 'Ajout échoué';

  @override
  String get saveBankAccount => 'Enregistrer ce compte';

  @override
  String get deleteAccountConfirmationTitle => 'Supprimer ce compte ?';

  @override
  String deleteAccountConfirmationMessage(String name) {
    return 'Voulez-vous vraiment supprimer le compte « $name » ?';
  }

  @override
  String get deleteFailed => 'Échec de la suppression';

  @override
  String get noBankAccount => 'Aucun compte bancaire enregistré';

  @override
  String get noBankAccountDescription => 'Ajoutez un compte à votre nom pour recevoir des virements et effectuer des retraits.';

  @override
  String get myBankAccounts => 'Mes comptes bancaires';

  @override
  String get defaultAccountName => 'Mon compte';

  @override
  String ribMaskedFormat(String rib) {
    return '•••• $rib';
  }

  @override
  String get myWalletRib => 'Mon RIB Wydad Pay';

  @override
  String get accountHolder => 'Titulaire du compte';

  @override
  String get defaultAccountHolder => 'Titulaire du compte';

  @override
  String get bank => 'Banque';

  @override
  String get defaultBank => 'Banque';

  @override
  String get transferInfo1 => 'Utilisez ce RIB pour effectuer un virement vers votre portefeuille Wydad Pay.';

  @override
  String get transferInfo2 => 'Vérifiez les informations bancaires avant de confirmer votre virement.';

  @override
  String get transferInfo3 => 'Le délai de réception dépend de votre établissement bancaire.';

  @override
  String get walletTransferInvalidPhone => 'Numéro de téléphone invalide';

  @override
  String get walletTransferMinimumAmount => 'Le montant minimum est de 10 MAD';

  @override
  String get walletTransferPinFourDigits => 'Le code PIN doit contenir 4 chiffres';

  @override
  String get walletTransferFailed => 'Le transfert a échoué. Veuillez réessayer.';

  @override
  String get walletTransferSuccess => 'Transfert effectué avec succès';

  @override
  String get walletTransferTitle => 'Transfert d\'argent';

  @override
  String get walletTransferRecipientQuestion => 'À qui souhaitez-vous envoyer de l\'argent ?';

  @override
  String get walletTransferRecipientWalletActive => 'Le bénéficiaire doit disposer d\'un compte Wydad Pay actif.';

  @override
  String get walletTransferPhoneNumber => 'Numéro de téléphone';

  @override
  String get walletTransferContinue => 'Continuer';

  @override
  String get walletTransferAmountToSend => 'Montant à envoyer';

  @override
  String get walletTransferOptionalMessage => 'Message facultatif';

  @override
  String get walletTransferNoteHint => 'Ajouter un message';

  @override
  String get walletTransferYouSend => 'Vous envoyez';

  @override
  String get walletTransferBeneficiary => 'Bénéficiaire';

  @override
  String get walletTransferMessage => 'Message';

  @override
  String get walletTransferEnterPin => 'Saisissez votre code PIN';

  @override
  String get walletTransferConfirm => 'Confirmer le transfert';

  @override
  String get walletTransferCreditSent => 'Votre transfert a bien été envoyé';

  @override
  String get walletTransferDate => 'Date';

  @override
  String get walletTransferPhone => 'Téléphone';

  @override
  String get walletTransferReference => 'Référence';

  @override
  String get walletTransferBackToWallet => 'Retour au portefeuille';

  @override
  String walletTransferToRecipient(String recipient) {
    return 'Transfert vers $recipient';
  }

  @override
  String get walletWithdrawMyWydadPayAccount => 'Mon compte Wydad Pay';

  @override
  String get walletWithdrawBankAccount => 'Compte bancaire';

  @override
  String get walletWithdrawNoBankAccount => 'Aucun compte bancaire enregistré';

  @override
  String get walletWithdrawPinFourDigits => 'Le code PIN doit contenir 4 chiffres';

  @override
  String get walletWithdrawMinimumAmount => 'Le montant minimum est de 50 MAD';

  @override
  String get walletWithdrawInsufficientBalance => 'Solde insuffisant';

  @override
  String get walletWithdrawTransferFailed => 'Le virement a échoué. Veuillez réessayer.';

  @override
  String get walletWithdrawDeleteAccountTitle => 'Supprimer ce compte bancaire ?';

  @override
  String walletWithdrawDeleteAccountMessage(String name) {
    return 'Voulez-vous vraiment supprimer le compte « $name » ?';
  }

  @override
  String get walletWithdrawCancel => 'Annuler';

  @override
  String get walletWithdrawDelete => 'Supprimer';

  @override
  String get walletWithdrawDeleteFailed => 'Échec de la suppression du compte';

  @override
  String get walletWithdrawBankTitle => 'Retrait vers un compte bancaire';

  @override
  String get walletWithdrawDestinationAccount => 'Compte de destination';

  @override
  String get walletWithdrawAddAnotherAccount => 'Ajouter un autre compte';

  @override
  String get walletWithdrawAmount => 'Montant à retirer';

  @override
  String walletWithdrawBalance(String amount) {
    return 'Solde : $amount MAD';
  }

  @override
  String get walletWithdrawEstimatedReception => 'Réception estimée';

  @override
  String get walletWithdrawEnterPin => 'Saisissez votre code PIN';

  @override
  String walletWithdrawButton(String amount) {
    return 'Retirer $amount MAD';
  }

  @override
  String get walletWithdrawInMyName => 'À mon nom';

  @override
  String walletWithdrawRib(String rib) {
    return 'RIB : $rib';
  }

  @override
  String get walletWithdrawDefault => 'Par défaut';

  @override
  String get walletWithdrawEmptyAccounts => 'Aucun compte bancaire disponible';

  @override
  String get walletWithdrawTransferSent => 'Votre demande de retrait a été envoyée';

  @override
  String walletWithdrawToAccount(String name) {
    return 'Vers le compte $name';
  }

  @override
  String get walletWithdrawStatus => 'Statut';

  @override
  String get walletWithdrawProcessing => 'En cours de traitement';

  @override
  String get walletWithdrawDate => 'Date';

  @override
  String get walletWithdrawEstimatedReceptionLabel => 'Délai de réception estimé';

  @override
  String get walletWithdrawEstimatedReceptionValue => 'Selon les délais de traitement bancaire';

  @override
  String get walletWithdrawBackToWallet => 'Retour au portefeuille';

  @override
  String get walletWithdrawCashTitle => 'Retrait en espèces';

  @override
  String get walletWithdrawAmountToWithdraw => 'Montant à retirer';

  @override
  String walletWithdrawCashBalance(String balance) {
    return 'Solde : $balance MAD';
  }

  @override
  String get walletWithdrawCashDescription => 'Retirez votre argent dans une agence Chaabi Cash, Damane Cash ou Tashilat.';

  @override
  String get walletWithdrawFailed => 'Le retrait a échoué. Veuillez réessayer.';

  @override
  String get walletWithdrawConnectionError => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get walletWithdrawAgencyInstructions => 'Présentez ce code et votre pièce d\'identité nationale au guichet pour récupérer votre argent.';

  @override
  String get walletWithdrawGetCode => 'Obtenir mon code de retrait';

  @override
  String get walletWithdrawCodeInstructions => 'Présentez ce code et votre pièce d\'identité nationale au guichet pour récupérer votre argent.';

  @override
  String get walletWithdrawCodeLabel => 'CODE DE RETRAIT';

  @override
  String get walletWithdrawAmountLabel => 'Montant';

  @override
  String get walletWithdrawBlockedAmountInfo => 'Le montant est réservé sur votre solde. Si vous ne le retirez pas avant son expiration, il sera recrédité sur votre portefeuille.';

  @override
  String get walletWithdrawBackToHome => 'Retour à l\'accueil';

  @override
  String get walletWithdrawChooseMethod => 'Choisissez votre méthode de retrait';

  @override
  String walletWithdrawAvailableBalance(String balance) {
    return 'Solde disponible : $balance MAD';
  }

  @override
  String get walletWithdrawBankSubtitle => 'Recevoir l\'argent sur votre compte bancaire';

  @override
  String get walletWithdrawCashAgency => 'Retrait en espèces';

  @override
  String get walletWithdrawCashSubtitle => 'Retirer l\'argent dans une agence partenaire';

  @override
  String get walletWithdrawTitle => 'Retirer de l\'argent';

  @override
  String get quizLoading => 'Chargement du quiz...';

  @override
  String quizQuestionProgress(String current, String total) {
    return 'Question $current sur $total';
  }

  @override
  String get quizOfTheDay => 'Quiz du jour';

  @override
  String quizQuestionsAboutClub(String count) {
    return '$count questions sur le club';
  }

  @override
  String quizQuestionsCount(String count) {
    return '$count questions';
  }

  @override
  String get quizRewards => 'Récompenses';

  @override
  String get quizQuestionsLabel => 'Questions';

  @override
  String get quizPerQuestion => 'Par question';

  @override
  String get quizDuration => 'Durée';

  @override
  String get quizSeconds => 'secondes';

  @override
  String quizMinutes(String count) {
    return '$count minutes';
  }

  @override
  String get quizCorrectAnswerLabel => 'Bonne réponse';

  @override
  String get quizYourAnswerLabel => 'Votre réponse';

  @override
  String get quizAnswerQuickly => 'Répondez rapidement !';

  @override
  String get quizGoodAnswers => 'Bonnes réponses';

  @override
  String quizPoints(String points) {
    return '$points points';
  }

  @override
  String get quizParticipatingInDraw => 'Vous participez au tirage au sort';

  @override
  String get quizDefaultReward => 'Récompense du quiz';

  @override
  String get quizBackHome => 'Retour à l\'accueil';

  @override
  String quizScoreSaved(String score, String total) {
    return 'Votre score de $score/$total a été enregistré';
  }

  @override
  String get quizTomorrowAt => 'Prochain quiz demain à';

  @override
  String quizCorrectAnswerExplanation(String answer) {
    return 'La bonne réponse est : $answer';
  }

  @override
  String get myAccount => 'Mon compte';

  @override
  String get defaultAccountType => 'Compte';

  @override
  String get namePlaceholder => 'Nom complet';

  @override
  String get verified => 'Vérifié';

  @override
  String get accountType => 'Type de compte';

  @override
  String get accountLevel => 'Niveau du compte';

  @override
  String accountLevelWithValue(String level) {
    return 'Niveau $level';
  }

  @override
  String get accountLimit => 'Plafond';

  @override
  String get identityVerification => 'Vérification d\'identité';

  @override
  String get kycPhoneVerified => 'Téléphone vérifié';

  @override
  String get kycPersonalInfo => 'Informations personnelles';

  @override
  String get kycAddress => 'Adresse';

  @override
  String get kycCin => 'CIN';

  @override
  String get kycSelfie => 'Selfie';

  @override
  String get changePin => 'Changer le code PIN';

  @override
  String get logoutWalletSession => 'Se déconnecter du portefeuille';

  @override
  String get walletSessionClosed => 'Session du portefeuille fermée';

  @override
  String get addAccountInMyName => 'Ajouter un compte à mon nom';

  @override
  String get addAccountSubtitle => 'Ajoutez un compte bancaire à votre nom pour effectuer vos opérations en toute simplicité.';

  @override
  String get accountNameLabel => 'Nom du compte';

  @override
  String get ribLabel => 'RIB (numéro de compte bancaire)';

  @override
  String get useWalletPhone => 'Utiliser le numéro de téléphone du portefeuille';

  @override
  String get associatedPhoneLabel => 'Numéro de téléphone associé';

  @override
  String get phoneHintShort => '6 12 34 56 78';

  @override
  String get ribWarning => 'Vérifiez bien votre RIB avant l\'enregistrement. Il ne pourra plus être modifié par la suite.';

  @override
  String get saveThisAccount => 'Enregistrer ce compte';

  @override
  String get newBankAccount => 'Nouveau compte bancaire';

  @override
  String get ribMustBe24Digits => 'Le RIB doit contenir 24 chiffres';

  @override
  String get addBeneficiaryFailed => 'Échec de l\'ajout du compte';

  @override
  String get receivePayment => 'Recevoir un paiement';

  @override
  String get accountManagement => 'Gestion du compte';

  @override
  String get payBill => 'Payer une facture';

  @override
  String get payMerchant => 'Payer un commerçant';

  @override
  String get giftCards => 'Cartes cadeaux';

  @override
  String get myCards => 'Mes cartes';

  @override
  String get availableSection => 'Disponibles';

  @override
  String get soonSection => 'Bientôt disponibles';

  @override
  String get soonLabel => 'BIENTÔT';

  @override
  String comingSoonMessage(String label) {
    return '$label bientôt disponible';
  }

  @override
  String get allServices => 'Tous les services';

  @override
  String get mobileRecharge => 'Recharge mobile';

  @override
  String get topUp => 'Recharger';

  @override
  String get transferAction => 'Transférer';

  @override
  String get withdraw => 'Retirer';

  @override
  String get history => 'Historique';

  @override
  String get myWalletAccounts => 'Mes comptes portefeuille';

  @override
  String get eachAccountLinkedToPhone => 'Chaque compte est lié à un numéro de téléphone.';

  @override
  String get phoneMaskPlaceholder => '•••• •••• ••';

  @override
  String accountHolderBalance(String holder, String balance) {
    return '$holder · $balance MAD';
  }

  @override
  String get holder => 'Titulaire';

  @override
  String get balancePlaceholder => '—';

  @override
  String get accountAddSoon => 'L\'ajout d\'un autre compte sera bientôt disponible';

  @override
  String get addWalletAccount => 'Ajouter un compte portefeuille';

  @override
  String get historyTitle => 'Historique';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get filterRecharges => 'Recharges';

  @override
  String get filterSent => 'Envoyés';

  @override
  String get filterReceived => 'Reçus';

  @override
  String get filterCashOut => 'Retraits';

  @override
  String get noTransactions => 'Aucune transaction';

  @override
  String get levelLabel => 'Niveau';

  @override
  String get subscriptionComingSoonMessage => 'L\'abonnement Wydad Pay sera bientôt disponible. Restez à l\'écoute !';

  @override
  String get digitalWallet => 'PORTEFEUILLE NUMÉRIQUE';

  @override
  String get verifiedBadge => 'VÉRIFIÉ';

  @override
  String get availableBalanceLabel => 'Solde disponible';

  @override
  String get moreAction => 'Plus';

  @override
  String get latestOperations => 'Dernières opérations';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noOperation => 'Aucune opération';

  @override
  String get subscriptionLabel => 'ABONNEMENT';

  @override
  String get season2026_27 => 'Saison 2026/27';

  @override
  String get supporterNamePlaceholder => 'Nom du supporter';

  @override
  String get tribuneInfoPlaceholder => 'Tribune • Place';

  @override
  String get showQRAccess => 'Afficher l\'accès QR';

  @override
  String get nextMatch => 'Prochain match';

  @override
  String get resellMatch => 'Revendre le match';

  @override
  String get subscriptionDetails => 'Détails de l\'abonnement';

  @override
  String get renewSubscription => 'Renouveler l\'abonnement';

  @override
  String get amountToDeposit => 'Montant à déposer';

  @override
  String get cashAgencyDescription => 'Dépôt en espèces en agence';

  @override
  String get minAmount50 => 'Le montant minimum est de 50 MAD';

  @override
  String get operationFailedContactSupport => 'Opération échouée. Veuillez contacter le support.';

  @override
  String get connectionErrorRetry => 'Erreur de connexion. Veuillez réessayer.';

  @override
  String get cashAgencyInfo => 'Présentez ce code et votre pièce d\'identité dans une agence partenaire (Chaabi Cash, Damane Cash, Tashilat) pour finaliser le dépôt.';

  @override
  String get getMyDepositCode => 'Obtenir mon code de dépôt';

  @override
  String get presentCodeAndCin => 'Présentez ce code et votre pièce d\'identité nationale au guichet.';

  @override
  String get depositCodeLabel => 'CODE DE DÉPÔT';

  @override
  String get amountLabel => 'Montant';

  @override
  String get balanceWillBeCredited => 'Le montant sera crédité sur votre solde dès que le dépôt sera vérifié.';

  @override
  String get cardsLoadFailed => 'Échec du chargement des cartes';

  @override
  String get amountBetween50And1000 => 'Le montant doit être compris entre 50 et 1000 MAD';

  @override
  String get loadingCardsInProgress => 'Chargement des cartes...';

  @override
  String get noSavedCard => 'Aucune carte enregistrée';

  @override
  String get pleaseSelectCard => 'Veuillez sélectionner une carte';

  @override
  String get invalidCvv => 'CVV invalide';

  @override
  String get genericErrorContactSupport => 'Une erreur s\'est produite. Veuillez contacter le support.';

  @override
  String get paymentCancelledOrFailed => 'Paiement annulé ou échoué';

  @override
  String get updatingBalance => 'Mise à jour du solde...';

  @override
  String get rechargeAction => 'Recharger';

  @override
  String get topUpYourWalletAmount => 'Rechargez votre portefeuille';

  @override
  String get transactionLimitLevel1 => 'Plafond de transaction : 1000 MAD (Niveau 1)';

  @override
  String get totalToPay => 'Total à payer';

  @override
  String get loadingCards => 'Chargement des cartes...';

  @override
  String get retryLoadCards => 'Réessayer le chargement des cartes';

  @override
  String get noCardRefresh => 'Aucune carte. Appuyez pour actualiser';

  @override
  String get paymentCard => 'Carte de paiement';

  @override
  String selectCardToPay(String amount) {
    return 'Sélectionnez la carte pour payer $amount MAD';
  }

  @override
  String get noSavedCards => 'Aucune carte enregistrée';

  @override
  String get addCardFromProfile => 'Ajoutez une carte depuis votre profil';

  @override
  String get refresh => 'Actualiser';

  @override
  String get cardDefault => 'Carte';

  @override
  String get maskedPanPlaceholder => '•••• •••• •••• ••••';

  @override
  String get confirmationTitle => 'Confirmation du paiement';

  @override
  String get enterCvvPrompt => 'Entrez le CVV de votre carte';

  @override
  String get cvvHint => 'CVV';

  @override
  String get rechargeDone => 'Recharge effectuée !';

  @override
  String get rechargeSuccessMessage => 'Votre portefeuille a été rechargé avec succès.';

  @override
  String get rechargedAmount => 'Montant rechargé';

  @override
  String get newBalance => 'Nouveau solde';

  @override
  String get later => 'Plus tard';

  @override
  String get createYourAccount => 'Créez votre compte';

  @override
  String get registerSubtitle => 'Rejoignez la communauté Wydad et accédez à toutes les fonctionnalités';

  @override
  String get emailHint => 'votre@email.com';

  @override
  String get phoneVerificationNote => 'Un code de vérification sera envoyé à ce numéro';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordMinHint => 'Minimum 6 caractères';

  @override
  String get passwordStrengthHint => 'Utilisez lettres, chiffres et symboles pour un mot de passe fort';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Retapez votre mot de passe';

  @override
  String get acceptTermsText => 'J\'accepte les conditions générales';

  @override
  String get acceptTermsRequired => 'Vous devez accepter les conditions générales';

  @override
  String get createMyAccount => 'Créer mon compte';

  @override
  String get alreadyRegistered => 'Déjà inscrit ? ';

  @override
  String get loginLink => 'Se connecter';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous pour accéder à vos tickets et votre portefeuille';

  @override
  String get passwordHintLogin => 'Entrez votre mot de passe';

  @override
  String get noAccountYet => 'Pas encore de compte ? ';

  @override
  String get createAccountLink => 'S\'inscrire';

  @override
  String get onboardingSlide1Title => 'Tous vos tickets au même endroit';

  @override
  String get onboardingSlide1Text => 'Achetez, transférez et gérez vos tickets des matchs du Wydad directement depuis l\'application.';

  @override
  String get onboardingSlide2Title => 'Wydad Pay, votre portefeuille numérique';

  @override
  String get onboardingSlide2Text => 'Rechargez, transférez et payez facilement avec votre portefeuille Wydad Pay sécurisé.';

  @override
  String get onboardingSlide3Title => 'Vivez l\'expérience Wydad';

  @override
  String get onboardingSlide3Text => 'Votez pour votre homme du match, jouez aux quiz et gagnez des prix exclusifs.';

  @override
  String get alreadyHaveAccount => 'J\'ai déjà un compte';

  @override
  String get continueWithoutAccount => 'Continuer sans compte';

  @override
  String get mockTicketplace => 'TICKETPLACE';

  @override
  String get mockResale => 'Revente entre supporters';

  @override
  String get mockFrom => 'Dès';

  @override
  String get mockFanZone => 'FAN ZONE';

  @override
  String get mockManOfMatch => 'Homme du match';

  @override
  String get mockLiveVote => 'VOTE EN DIRECT';

  @override
  String get mockTicket => 'TICKET';

  @override
  String get mockPremium => 'PREMIUM';

  @override
  String get mockStadium => 'Stade';

  @override
  String get mockGateSeat => 'Porte A · Place 24';

  @override
  String get mockSubscription => 'ABONNEMENT';

  @override
  String get mockSeason => 'Saison 2026/27';

  @override
  String get mockWydadPay => 'WYDAD PAY';

  @override
  String get mockAvailableBalance => 'Solde disponible';

  @override
  String get mockTopUp => 'Recharger';

  @override
  String get mockTransfer => 'Transférer';

  @override
  String get mockWithdraw => 'Retirer';

  @override
  String get mockMore => 'Plus';

  @override
  String get mockMatchPlayer => 'Homme du match';

  @override
  String get mockLive => 'EN DIRECT';

  @override
  String get mockQuizOfDay => 'Quiz du jour';

  @override
  String get mockWinTickets => 'Gagnez des tickets';

  @override
  String get chooseCategory => 'Choisir une catégorie';

  @override
  String quantityRequestedExceedsStock(String requested, String available) {
    return 'Demandé : $requested, disponible : $available';
  }

  @override
  String get productUnavailable => 'Produit indisponible';

  @override
  String get maillotsOfficiel => 'MAILLOT OFFICIEL';

  @override
  String get visaMastercard3ds => 'Visa / Mastercard · 3D Secure';

  @override
  String get wydadPayLabel => 'Wydad Pay';

  @override
  String get stadiumName => 'Stade Mohammed V';

  @override
  String get transfersButton => 'Transferts';

  @override
  String get matchPlaceholder => 'Match';

  @override
  String pendingTransferLabel(String count) {
    return 'Transferts en attente ($count)';
  }

  @override
  String get senderPlaceholder => 'Supporter';

  @override
  String receivedTicketFrom(String name) {
    return 'Ticket reçu de $name';
  }

  @override
  String get inPendingLabel => 'En attente';

  @override
  String get transferAcceptInfo => 'Acceptez le transfert pour recevoir le ticket dans votre compte.';

  @override
  String get refuse => 'Refuser';

  @override
  String myOrdersSection(String count) {
    return 'Mes commandes ($count)';
  }

  @override
  String get paidLabel => 'Payé';

  @override
  String get receivedLabel => 'Reçu';

  @override
  String get transferredLabel => 'Transféré';

  @override
  String get walletLabel => 'Wydad Pay';

  @override
  String paidOnPayment(String date, String method) {
    return 'Payé le $date · via $method';
  }

  @override
  String get ticketFallback => 'Ticket';

  @override
  String get validLabel => 'Valide';

  @override
  String ticketNumberLabel(String number) {
    return 'N°$number';
  }

  @override
  String get billetterie => 'BILLETTERIE';

  @override
  String get maxPerAccount => 'max par compte';

  @override
  String get available => 'Disponible';

  @override
  String get soldOut => 'Épuisé';

  @override
  String get fewSeatsLeft => 'Peu de places restantes';

  @override
  String get paymentMethodLabel => 'Moyen de paiement';

  @override
  String get insufficientBalance => 'Solde insuffisant';

  @override
  String get pinCodeLabel => 'Code PIN';

  @override
  String get pinCodeHint => 'Code PIN à 4 chiffres';

  @override
  String get cardBankLabel => 'Carte bancaire';

  @override
  String get payByCard => 'Payer en toute sécurité par carte';

  @override
  String get pinRequired => 'Veuillez saisir votre code PIN à 4 chiffres';

  @override
  String get genericErrorMsg => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get processingTitle => 'Traitement du paiement...';

  @override
  String get processingSubtitle => 'Veuillez patienter un instant';

  @override
  String get paymentSuccessTitle => 'Paiement réussi';

  @override
  String get paymentSuccessMessage => 'Votre paiement a été traité avec succès.';

  @override
  String get backToEvents => 'Retour aux événements';

  @override
  String get myInfoSection => 'MES INFORMATIONS';

  @override
  String get passwordSection => 'MOT DE PASSE';

  @override
  String get supporterWac => 'Supporter du WAC';

  @override
  String get cinHintFull => 'Ex : BK123456';

  @override
  String get newPasswordHintMin => 'Minimum 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre';

  @override
  String get inProgressSection => 'EN COURS';

  @override
  String get previousSection => 'PRÉCÉDENTES';

  @override
  String get myOrdersTitle => 'Mes commandes';

  @override
  String get orderLabel => 'Commande';

  @override
  String itemsCount(String count) {
    return '$count article(s)';
  }

  @override
  String get passedOn => 'Passée le';

  @override
  String get deliveryExpected => 'Livraison estimée';

  @override
  String get carrier => 'Transporteur';

  @override
  String get carrierName => 'Wydad Express';

  @override
  String get deliveredStatus => 'Livré';

  @override
  String get stepConfirmed => 'Confirmée';

  @override
  String get stepPrepared => 'Préparée';

  @override
  String get stepShipped => 'Expédiée';

  @override
  String get stepDelivered => 'Livrée';

  @override
  String get statusLabel => 'Statut';

  @override
  String get paymentLabel => 'Paiement';

  @override
  String get deliveryInfoSection => 'INFOS LIVRAISON';

  @override
  String get daysShort => 'j';

  @override
  String get hoursShort => 'h';

  @override
  String get transferTicketTitle => 'Transférer le ticket';

  @override
  String get transferTicketPrompt => 'Saisissez l\'email du destinataire';

  @override
  String get errorCustomerId => 'Erreur : ID client manquant';

  @override
  String get transferDone => 'Transfert effectué';

  @override
  String get categoryLabel => 'Catégorie';

  @override
  String get ticketDetailTitle => 'Détails du ticket';

  @override
  String get ticketStatusLabel => 'Statut du ticket';

  @override
  String get transferTicket => 'Transférer';

  @override
  String get wallet => 'Portefeuille';

  @override
  String get referenceLabel => 'Référence';
}
