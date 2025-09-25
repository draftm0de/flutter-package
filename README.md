# Draftmode Flutter Wrappers

## Localisation
We´re providing for 
- english (en)
- german (de)
a localization dictionary.

### implementation in your app
/app.dart or /main.dart
```
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:draftmode/localizations.dart'; // DraftmodeLocalizations

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      builder: (context) => PlatformApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          DraftModeLocalizations.delegate,
          AppLocalizations.delegate,
        ],
```