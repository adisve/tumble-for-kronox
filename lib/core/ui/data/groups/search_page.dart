import 'package:tumble/core/ui/data/string_constant_group.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchPageStrings extends StringConstantGroup {
  SearchPageStrings(AppLocalizations localizedStrings) : super(localizedStrings);

  String title() => localizedStrings.searchPageTitle;
  String searchBarUnfocusedPlaceholder() => localizedStrings.searchBarUnfocusedPlaceholder;
  String searchBarFocusedPlaceholder() => localizedStrings.searchBarFocusedPlaceholder;
  String toScheduleView() => localizedStrings.searchPageToScheduleViewButton;
  String results(int numOfResults) => localizedStrings.searchPageResults(numOfResults);
}
