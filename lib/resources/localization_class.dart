import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class Localization {
  Localization(this.locale);

  final Locale locale;

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'sharedContact': 'Shared contact',
      'image': 'Image',
      'somethingWentWrong': 'Something went wrong. Please try again later',
      'startNewConversation': 'Start a new conversation',
      'shareContact': 'Share Contact',
      'messages': 'Messages',
      'contacts': 'Contacts',
      'users': 'Users',
      'all': 'All',
      'lastAccessed': 'Last accessed',
      'favorites': 'Favorites',
      'logo': 'Logo',
      'createAnAccount': 'Create an Account',
      'name': 'Name',
      'location': 'Location',
      'phoneNumber': 'Phone number',
      'phoneNumberHint': '+x xxx-xxx-xxxx',
      'continue': 'Continue',
      'alreadyRegisteredQuestion': 'Already have an account?',
      'termsAndConditions': 'Terms and Conditions',
      'verificationCode': 'Verification Code',
      'login': 'Login',
      'lastEdit': 'Last Edit on June 2, 2017',
      'typeCodeHere': 'Type code here',
      'error': 'Error',
      'ok': 'Ok',
      'nameValidation': 'Please provide a valid name',
      'locationValidation': 'Please provide a valid location',
      'phoneNumberValidation': '#### (###) ### - Enter a valid phone number',
      'verificationCodeValidation': 'The verification code cannot be empty',
      'loginErrorMessage':
          'There is no user associated with this phone number.',
      'alreadySignedUp':
          'There is already an account associated with this phone number.',
      'termsAndConditionsText': 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod '
          'tempor incididunt ut ero labore et dolore magna aliqua.'
          ' Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti '
          'laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor '
          'in reprehenderit in uienply voluptate velit esse cillum dolore eu fugiat '
          'nulla pariatur. Excepteur sint occaecat cupidatat norin proident, sunt in '
          'culpa qui officia deserunt mollit anim id est laborum Lorem ipsum dolor sit '
          'amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut ero '
          'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud ex',
      'accessAgenda': 'We need to access your agenda',
      'tutorialContent':
          'Have moving you midst above may. Is one tree likness was light. Green fifth I subdue dont\'t, '
              'good one was Creature bearing you signs years may. Seas kind second dry made lights his '
              'over two their spirit saying image.',
      'tagYourFriends': 'Tag your friends',
      'syncContactsMessage':
          'Your phone agenda/recent calls are being synced to our database',
      'myProfile': 'My profile',
      'settings': 'Settings',
      'signOut': 'Sign Out',
      'changeProfilePhoto': 'Change Profile Photo',
      'nameSurname': 'Name Surname',
      'main': 'Main #',
      'housekeeper': '#housekeeper',
      'tagValidation': 'This field cannot be empty',
      'bio': 'Bio',
      'skills': 'Skills',
      'addMoreSkills': 'Add more skills',
      'add': 'Add',
      'LoadMoreStatus.loading': 'Loading messages',
      'LoadMoreStatus.fail': 'Could not load messages',
      'viewAllReviews': 'View all reviews',
      'syncResults': 'Sync Results',
      'skip': 'Skip',
      'usersFoundInYourPhone': 'Users found in your phone',
      'existingUsers': 'Existing Users',
      'unjoinedContacts': 'Contacts that haven\'t joined',
      'shareSelected': 'Share Selected',
      'selectedTagsWillBeShared': 'Selected tags will be shared',
      'addTagsToPromoteYourFriends': 'Add tags to promote your friends',
      'addMoreTagsTotThePerson': 'Add more tags to the person',
      'tags': 'Tags',
      'selectedContactsWillBeShared':
          'The selected contacts will be shared behind the scene.',
      'imagePreview': 'Image Preview',
      'verificationCodeDescription':
          'A text message with a 6-digit verification code was just sent to ',
      'resendCode': 'Resend code',
      'cantRetry': 'You can\'t retry yet!',
      'addPost': 'Add Post',
      'isLookingFor': ' is looking for',
      'preview': 'Preview',
      'selectTagsYouAreLookingFor': 'Select tag you are looking for...',
      'tagsYouAreLookingFor': 'Tag you are looking for',
      'addMoreDetails': 'Add more details (optional)...',
      'createPostError': 'Please select the tag you are looking for!',
      'success': 'Success',
      'yourPostHasBeenSuccessfullyAdded':
          'Your post has been successfully added!',
      'addDescription': 'Add a description',
      'addATag': 'Add a tag',
      'deletePost': 'Delete Post',
      'recommendedBy': 'Recommended by ',
      'tapOnSkillToLeaveAReview': 'Tap on skill to leave a review',
      'leaveReview': 'Leave review',
      'typeAMessage': 'Type a message...',
      'publishReview': 'Publish Review',
      'emptyContactsList': 'Empty contacts list',
      'emptyUsersList': 'Empty users list',
      'reviewAdded': 'Your review was successfully added',
      'reviews': 'Reviews',
      'generalSettings': 'General Settings',
      'recommendSearchNotification': 'Recommend search notification',
      'messageNotification': 'Message notfication',
      'allowPushNotifications': 'Allow push notifications',
      'home': 'Home',
      'emptyPostsList': 'Empty posts list',
      'sendInChat': 'Send in Chat',
      'post': 'Post',
      'tapAndRecommendAFriend': 'Tap here and recommend a friend',
      'searchs': 'Searchs',
      'recentConversations': 'Recent Conversations',
      'send': 'Send',
      'allFriends': 'All friends',
      'usersWithTag': 'Users with ',
      'noUsersWith': 'There are no users with #',
      'Monday': 'Monday',
      'Tuesday': 'Tuesday',
      'Wednesday': 'Wednesday',
      'Thursday': 'Thursday',
      'Friday': 'Friday',
      'Saturday': 'Saturday',
      'Sunday': 'Sunday',
      'sharedPost': 'Shared Post',
      'today': 'Today',
      'replies': ' replies',
      'sentARecommend': ' sent a recommend for ',
      'noReviews': 'No reviews',
      'excellent': 'Excellent!',
      'veryGood': 'Very good!',
      'good': 'Good!',
      'poor': 'Poor!',
      'veryPoor': 'Very poor!',
      'emptyReviewsList': 'Empty reviews list',
   'createdConnection': 'Connection successfuly created',
   'deletedConnection': 'Connection deleted'
    },
    'ro': {
      'sharedContact': 'Contact distribuit',
      'image': 'Imagine',
      'somethingWentWrong':
          'Ceva nu a mers bine. Va rugam incercati mai tarziu',
      'startNewConversation': 'Creeaza o noua conversatie',
      'shareContact': 'Distribuie Contact',
      'messages': 'Mesaje',
      'contacts': 'Contacte',
      'users': 'Utilizatori',
      'all': 'Toate',
      'lastAccessed': 'Recente',
      'favorites': 'Favorite',
      'logo': 'Logo',
      'createAnAccount': 'Creaza un cont',
      'name': 'Nume',
      'location': 'Locatie',
      'phoneNumber': 'Numar de telefon',
      'phoneNumberHint': '+x xxx-xxx-xxxx',
      'continue': 'Continua',
      'alreadyRegisteredQuestion': 'Intra in cont',
      'termsAndConditions': 'Termeni \si Conditii',
      'verificationCode': 'Cod de Verificare',
      'login': 'Login',
      'lastEdit': 'Data ultimei actualizari: 2 Iunie, 2017',
      'typeCodeHere': 'Introduceti codul aici',
      'error': 'Eroare',
      'ok': 'Ok',
      'nameValidation': 'Introduceti un nume valid',
      'locationValidation': 'Introduceti o locatie valida',
      'phoneNumberValidation':
          '#### (###) ### - Introduceti un numar de telefon valid',
      'verificationCodeValidation': 'Introduceti codul de verificare',
      'loginErrorMessage':
          'Nu exista nici un cont asociat cu acest numar de telefon.',
      'alreadySignedUp': 'Exista un cont asociat cu acest numar de telefon.',
      'termsAndConditionsText': 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod '
          'tempor incididunt ut ero labore et dolore magna aliqua.'
          ' Ut enim ad minim veniam, quis nostrud exercitation ullamco poriti '
          'laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor '
          'in reprehenderit in uienply voluptate velit esse cillum dolore eu fugiat '
          'nulla pariatur. Excepteur sint occaecat cupidatat norin proident, sunt in '
          'culpa qui officia deserunt mollit anim id est laborum Lorem ipsum dolor sit '
          'amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut ero '
          'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud ex',
      'accessAgenda':
          'Pentru a functiona corect, aplicatia are nevoie sa acceseze lista de contacte',
      'tutorialContent':
          'Have moving you midst above may. Is one tree likness was light. Green fifth I subdue dont\'t,'
              ' good one was Creature bearing you signs years may. Seas kind second dry made lights his '
              'over two their spirit saying image.',
      'tagYourFriends': 'Eticheteaza prieteni',
      'syncContactsMessage':
          'Agenda telefonica/apelurile recente se sincronizeaza cu baza noastra de date.',
      'myProfile': 'Profilul meu',
      'settings': 'Setari',
      'signOut': 'Deconectare',
      'changeProfilePhoto': 'Modifica Imaginea de Profil',
      'nameSurname': 'Nume Prenume',
      'main': 'Main #',
      'housekeeper': '#housekeeper',
      'tagValidation': 'Campul nu trebuie sa fie gol.',
      'bio': 'Bio',
      'skills': 'Abilitati',
      'addMoreSkills': 'Adauga abilitati',
      'add': 'Adauga',
      'LoadMoreStatus.loading': 'Se incarca mesajele',
      'LoadMoreStatus.fail': 'Mesajele nu au putut fi incarcate',
      'viewAllReviews': 'Vezi toate recenziile',
      'syncResults': 'Rezultate',
      'skip': 'Inainte',
      'usersFoundInYourPhone': 'Utilizatori gasiti in telefon',
      'existingUsers': 'Utilizatori Existenti',
      'unjoinedContacts': 'Contacte care nu s-au alaturat aplicatiei',
      'shareSelected': 'Partajeaza selectia ',
      'selectedTagsWillBeShared': 'Etichetele selectate vor fi partajate',
      'addTagsToPromoteYourFriends':
          'Adauga etichete pentru a-ti promova prietenii',
      'addMoreTagsTotThePerson': 'Adauga mai multe etichete persoanei',
      'tags': 'Etichete',
      'selectedContactsWillBeShared':
          'Contactele selectate vor fi partajate in spatele scenei.',
      'imagePreview': 'Vizualizare Imagine',
      'verificationCodeDescription':
          'Un mesaj text cu un code de verificare din 6 cifre a fost trimis catre ',
      'resendCode': 'Retrimite codul',
      'cantRetry': 'Inca nu puteti retrimite codul!',
      'addPost': 'Adauga o postare',
      'isLookingFor': ' cauta',
      'preview': 'Previzualizare',
      'selectTagsYouAreLookingFor': 'Selecteaza etichetea pe care le cauti',
      'tagsYouAreLookingFor': 'Eticheta pe care o cauti...',
      'addMoreDetails': 'Adauga mai multe detalii (optional)...',
      'createPostError': 'Va rugam selectati tag-ul pe care il cautati',
      'success': 'Succes',
      'yourPostHasBeenSuccessfullyAdded': 'Postarea a fost adaugata cu succes!',
      'addDescription': 'Adauga o descriere',
      'addATag': 'Adauga un tag',
      'deletePost': 'Sterge Postarea',
      'recommendedBy': 'Recomandat de ',
      'tapOnSkillToLeaveAReview':
          'Apasa pe o abilitate pentru a lasa o recenzie',
      'leaveReview': 'Lasa o recenzie',
      'typeAMessage': 'Scrie un mesaj...',
      'publishReview': 'Publica Recenzia',
      'emptyContactsList': 'Nu exista contacte in telefon',
      'emptyUsersList': 'Nu exista utilizatori',
      'reviewAdded': 'Recenzia dumneavoastra a fost adaugata cu succes!',
      'reviews': 'Recenzii',
      'generalSettings': 'Setari Generale',
      'recommendSearchNotification': 'Notificare de cautare a recomandarilor',
      'messageNotification': 'Notificare mesaj',
      'allowPushNotifications': 'Permiteti notificari',
      'home': 'Acasa',
      'emptyPostsList': 'Nu exista postari',
      'sendInChat': 'Trimite',
      'post': 'Postare',
      'tapAndRecommendAFriend': 'Recomanda un prieten',
      'searchs': 'Cautari',
      'recentConversations': 'Conversatii recente',
      'send': 'Trimite',
      'allFriends': 'Toti prietenii',
      'usersWithTag': 'Utilizatori cu ',
      'noUsersWith': 'Nu exista utilizatori cu #',
      'Monday': 'Luni',
      'Tuesday': 'Marti',
      'Wednesday': 'Miercuri',
      'Thursday': 'Joi',
      'Friday': 'Vineri',
      'Saturday': 'Sambata',
      'Sunday': 'Duminica',
      'sharedPost': 'Postare distribuita',
      'today': 'Astazi',
      'replies': ' raspunsuri',
      'sentARecommend': ' a trimis o recomandare pentru ',
      'noReviews': 'Nici o recenzie',
      'excellent': 'Excelent!',
      'veryGood': 'Foarte bun!',
      'good': 'Bun!',
      'poor': 'Slab!',
      'veryPoor': 'Foarte slab!',
   'emptyReviewsList': 'Nu exista nici un review',
   'createdConnection': 'Conexiune creata',
   'deletedConnection': 'Conexiune stearsa'
    },
  };

  String getString(String string) {
    return _localizedValues[locale.languageCode][string];
  }

  String getFormattedDateTime(DateTime dateTime) {
    if (DateTime.now().day == dateTime.day &&
        DateTime.now().month == dateTime.month &&
        DateTime.now().year == dateTime.year) {
      return getString('today');
    } else {
      if (DateTime.now().difference(dateTime) <
          Duration(seconds: DateTime.daysPerWeek * 24 * 3600)) {
        return getString(DateFormat("EEEE").format(dateTime));
      } else {
        return DateFormat("dd/MM/yyyy").format(dateTime);
      }
    }
  }
}
