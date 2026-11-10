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
  String get lightMode => 'Mode clair';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'عربي';

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
  String get noQuizAvailableToday => 'Aucun quiz disponible pour aujourd\'hui';

  @override
  String get unableToLoadQuizzes => 'Impossible de charger les quiz';

  @override
  String get alreadyParticipated => 'Déjà participé';

  @override
  String get alreadyParticipatedMessage => 'Vous avez déjà participé à ce quiz. La participation est prise en compte une seule fois.';

  @override
  String get missingInformation => 'Information manquante';

  @override
  String get loginToSaveScore => 'Veuillez vous connecter pour que votre score soit enregistré.';

  @override
  String get yourScoreOf => 'Votre score de';

  @override
  String get hasBeenSaved => 'a été enregistré !';

  @override
  String get scoreNotSaved => 'Votre score n\'a pas pu être enregistré. Veuillez réessayer.';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get expert => '🏆 Expert !';

  @override
  String get veryGood => '🌟 Très bien !';

  @override
  String get notBad => '👍 Pas mal !';

  @override
  String get studyMore => '📚 Encore un peu';

  @override
  String get keepGoing => '💪 Allez, on révise ?';

  @override
  String get winnersList => 'LISTE DES GAGNANTS';

  @override
  String get youParticipatedInQuiz => 'Vous avez participé à ce quiz';

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
  String get youHaveAlreadyParticipated => 'Vous avez déjà participé';

  @override
  String get startQuiz => 'COMMENCER LE QUIZ';

  @override
  String get first => '1ère';

  @override
  String get second => '2ème';

  @override
  String get third => '3ème';

  @override
  String get fourth => '4ème';

  @override
  String get fifth => '5ème';

  @override
  String get th => 'ème';

  @override
  String get place => 'place';

  @override
  String get correctAnswer => 'Bonne réponse !';

  @override
  String get wrongAnswer => 'Mauvaise réponse...';

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
}
