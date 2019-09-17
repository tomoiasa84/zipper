import 'dart:ui';

import 'package:flutter/cupertino.dart';

class Localization {
  Localization(this.locale);

  final Locale locale;

  static Localization of(BuildContext context) {
    return Localizations.of<Localization>(context, Localization);
  }

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'contacts': 'Contacts',
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
      'tagsFoundInYourPhone': 'Tags found in your phone',
      'publicTags': 'Public Tags',
      'untaggedContacts': 'Contacte Neetichetate',
      'shareSelected': 'Share Selected',
      'imagePreview': 'Image Preview'
    },
    'ro': {
      'contacts': 'Contacte',
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
      'syncResults': 'Rezultate sincronizare',
      'skip': 'Inainte',
      'tagsFoundInYourPhone': 'Etichete gasite in telefon',
      'publicTags': 'Etichete Publice',
      'untaggedContacts': 'Untagged Contacts',
      'shareSelected': 'Partajeaza selectia ',
      'imagePreview': 'Vizualizare Imagine'
    },
  };

  String getString(String string) {
    return _localizedValues[locale.languageCode][string];
  }
}
