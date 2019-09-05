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
          'Have moving you midst above may. Is one tree likness was light. Green fifth I subdue dont\'t, good one was Creature bearing you signs years may. Seas kind second dry made lights his over two their spirit saying image.',
      'tagYourFriends': 'Tag your friends',
      'syncContactsMessage':
          'Your phone agenda/recent calls are being synced to our database',
      'myProfile': 'My profile',
      'settings': 'Settings',
      'signOut': 'Sign Out',
    },
    'ro': {
      'contacts': 'Contacte',
      'all': 'Toate',
      'lastAccessed': 'Recente',
      'favorites': 'Favorite',
      'logo': 'Logo',
      'createAnAccount': 'Crează un cont',
      'name': 'Nume',
      'location': 'Locație',
      'phoneNumber': 'Număr de telefon',
      'phoneNumberHint': '+x xxx-xxx-xxxx',
      'continue': 'Continuă',
      'alreadyRegisteredQuestion': 'Intră în cont',
      'termsAndConditions': 'Termeni \și Condiții',
      'verificationCode': 'Cod de Verificare',
      'login': 'Login',
      'lastEdit': 'Data ultimei actualizări: 2 Iunie, 2017',
      'typeCodeHere': 'Introduceți codul aici',
      'ok': 'Ok',
      'nameValidation': 'Introduceți un nume valid',
      'locationValidation': 'Introduceți o locatie validă',
      'phoneNumberValidation':
          '#### (###) ### - Introduceți un număr de telefon valid',
      'verificationCodeValidation': 'Introduceți codul de verificare',
      'loginErrorMessage':
          'Nu există nici un cont asociat cu acest număr de telefon.',
      'alreadySignedUp': 'Există un cont asociat cu acest număr de telefon.',
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
          'Pentru a funcționa corect, aplicația are nevoie să acceseze lista de contacte',
      'tutorialContent':
          'Have moving you midst above may. Is one tree likness was light. Green fifth I subdue dont\'t, good one was Creature bearing you signs years may. Seas kind second dry made lights his over two their spirit saying image.',
      'tagYourFriends': 'Etichetează prieteni',
      'syncContactsMessage':
          'Agenda telefonică/apelurile recente se sincronizează cu baza noastră de date.',
      'myProfile': 'Profilul meu',
      'settings': 'Setări',
      'signOut': 'Deconectare',
    },
  };

  String getString(String string) {
    return _localizedValues[locale.languageCode][string];
  }
}
