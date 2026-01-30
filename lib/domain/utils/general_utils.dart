import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afya_id/ui/providers/general_provider.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '/ui/ui.dart';

class GeneralUtils {
  SearchBar generalSearchBar(
    BuildContext context, {
    required TextEditingController searchBarController,
    void Function(String)? onChanged,
    FocusNode? focusNode,
  }) {
    final provider = Provider.of<GeneralProvider>(context);
    return SearchBar(
      autoFocus: true,
      focusNode: focusNode,
      trailing: [
        if (searchBarController.text.isNotEmpty)
          IconButton(
            onPressed: () {
              searchBarController.clear();
              provider.recharge(searchBarController);
              onChanged?.call("");
            },
            icon: Icon(
              AppIcons.cancel,
              // color: ThemeUtil.allThemes(context).primaryColorDark,
            ),
          ),
      ],
      onTapOutside: (event) => FocusScope.of(context).unfocus(),
      onChanged: (value) {
        // provider.recharge(searchBarController);
        onChanged?.call("");
      },

      controller: searchBarController,
      hintText: 'Rechercher ici',
      hintStyle: WidgetStatePropertyAll(TextStyle(color: AppColors.grey)),

      // backgroundColor: WidgetStatePropertyAll(
      //   ThemeUtil.allThemes(context).scaffoldBackgroundColor,
      // ),
      elevation: const WidgetStatePropertyAll(0.0),

      side: WidgetStatePropertyAll(
        BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
    );
  }

  DropdownButtonFormField generalDropDownButton({
    required dynamic context,
    required String label,
    required List<String> items,
    required TextEditingController controller,
    void Function()? onChanged,
    void Function()? onTap,
    String? Function(dynamic)? validator,
    bool hasUnderlinedBorder = true,
    bool noBorder = false,
  }) {
    return DropdownButtonFormField(
      alignment: Alignment.center,
      onTap: onTap,
      validator: validator,
      isExpanded: true,
      isDense: true,
      initialValue: controller.text.isEmpty
          ? null
          : items.firstWhere(
              (element) => element == controller.text,
              orElse: () => items.first,
            ),
      borderRadius: BorderRadius.circular(appRadius),
      icon: const Icon(Icons.arrow_drop_down_rounded, size: 25),
      iconSize: 15,
      iconEnabledColor: AppColors.grey,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(
          context,
        ).textTheme.labelLarge!.copyWith(color: AppColors.grey),
        focusedErrorBorder: noBorder
            ? InputBorder.none
            : hasUnderlinedBorder
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(appRadius),
                borderSide: BorderSide(color: AppColors.red),
              ),
        errorBorder: noBorder
            ? InputBorder.none
            : hasUnderlinedBorder
            ? UnderlineInputBorder(borderSide: BorderSide(color: AppColors.red))
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(appRadius),
                borderSide: BorderSide(color: AppColors.red),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(appRadius),
          borderSide: BorderSide(color: AppColors.grey),
        ),
        // hintText: 'Dropdown button',
        focusedBorder: noBorder
            ? InputBorder.none
            : hasUnderlinedBorder
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(appRadius),
                borderSide: BorderSide(
                  width: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
        enabledBorder: noBorder
            ? InputBorder.none
            : hasUnderlinedBorder
            ? UnderlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(appRadius),
                borderSide: BorderSide(
                  width: 2,
                  color: Colors.grey.withValues(alpha: 0.3),
                ),
              ),
      ),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (value) {
        controller.text = value.toString();
        onChanged?.call();
      },
    );
  }

  Material generalButton({
    Color? backColor = Colors.transparent,
    Color? textColor = Colors.white,
    Widget? child,
    String text = "",
    double radius = 50,
    // double radius = 15,
    EdgeInsets? padding,
    VoidCallback? tapAction,
    void Function()? doubleTapAction,
    Color borderColor = Colors.transparent,
    void Function()? longPressAction,
  }) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: BorderSide(color: borderColor, width: 2),
      ),
      elevation: 0.0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      color: backColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),

        // autofocus: true,
        hoverColor: AppColors.grey.withValues(alpha: 0.3),
        splashColor: Colors.grey,
        onTap: tapAction,
        onDoubleTap: doubleTapAction,
        onLongPress: longPressAction,
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: borderColor, width: 2),
        ),
        child: Padding(
          padding:
              padding ?? EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Center(
            child: text.isNotEmpty
                ? Text(
                    text,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: borderColor != Colors.transparent
                          ? borderColor
                          : textColor,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }

  CupertinoActivityIndicator loadingContinious({
    required dynamic context,
    Color? color,
  }) {
    return CupertinoActivityIndicator(
      color: color ?? Theme.of(context).colorScheme.onSurface,
    );
  }

  Future<dynamic> confirmationDialog(
    dynamic context, {
    bool barrierDismissible = true,
    bool goBackAtEnd = true,
    required String text,
    required IconData icon,
    required Function()? onConfirm,
    String? confirmLabel,
    String? unConfirmLabel,
    Color? confirmColor,
    Color? unConfirmColor,
  }) {
    bool isLoading = false;
    return showCupertinoDialog(
      barrierDismissible: barrierDismissible,
      context: context,
      builder: (buildContext) {
        final consultationProvider = Provider.of<GeneralProvider>(context);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(
                buildContext,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          icon: Icon(icon, color: AppColors.red),
          content: Text(
            textAlign: TextAlign.center,
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              spacing: 10,
              // runSpacing: 10,
              // runAlignment: WrapAlignment.center,
              // crossAxisAlignment: WrapCrossAlignment.center,
              // alignment: WrapAlignment.center,
              children: [
                Expanded(
                  child: generalButton(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderColor: unConfirmColor ?? AppColors.grey,
                    tapAction: () {
                      Navigator.pop(context);
                    },
                    child: Center(
                      child: Text(
                        unConfirmLabel ?? "Annuler",
                        style: TextStyle(
                          color: unConfirmColor ?? AppColors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: generalButton(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    backColor:
                        confirmColor?.withValues(alpha: 0.1) ??
                        AppColors.red.withValues(alpha: 1),
                    tapAction: isLoading
                        ? null
                        : () async {
                            consultationProvider.recharge(isLoading = true);
                            await onConfirm?.call();
                            consultationProvider.recharge(isLoading = false);
                            if (goBackAtEnd) {
                              Navigator.pop(context);
                            }
                          },
                    child: isLoading
                        ? loadingContinious(
                            context: context,
                            color: confirmColor ?? AppColors.white0,
                          )
                        : Center(
                            child: Text(
                              confirmLabel ?? "Supprimer",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: confirmColor ?? AppColors.white0,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> generalWaiterPopUp(
    dynamic context, {
    bool goBackAtEnd = true,
    String? text,
    String? errorText,
    required Function()? action,
  }) async {
    showCupertinoDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        // Le dialogue contient l'indicateur de chargement
        return SimpleDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          children: [
            Text(
              textAlign: TextAlign.center,
              text ?? "Veuillez patienter...",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CupertinoActivityIndicator(
              radius: 15,
              // ... couleur ...
            ),
          ],
        );
      },
    );
    try {
      await action?.call();
    } catch (e) {
      snackbarMessage(context, text: errorText ?? "Une erreur est survenue");
    }
    if (goBackAtEnd) {
      Navigator.pop(context);
    }

    return null;
  }

  TextFormField generalTextInput(
    BuildContext context, {
    required TextEditingController textEditingController,
    bool onlyNumber = false,
    bool onlyDouble = false,
    String? hintText,
    String? suffixText,
    Icon? prefixIcon,
    bool centerText = false,
    bool underLinedBorder = false,
    bool noBorder = false,
    bool readOnly = false,
    void Function()? onCleared,
    void Function(String)? onChanged,
  }) {
    final provider = Provider.of<GeneralProvider>(context);

    return TextFormField(
      // scrollPadding: EdgeInsets.zero,
      onChanged: (value) {
        provider.recharge(textEditingController);

        onChanged?.call(value);
      },

      inputFormatters: onlyNumber
          ? [FilteringTextInputFormatter.digitsOnly]
          : onlyDouble
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,10}$'))]
          : [],

      keyboardType: onlyNumber ? TextInputType.number : TextInputType.text,
      controller: textEditingController,
      readOnly: readOnly,
      textAlign: centerText ? TextAlign.center : TextAlign.start,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        border: noBorder
            ? InputBorder.none
            : underLinedBorder
            ? UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.grey2),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(color: AppColors.grey2),
              ),
        // contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),

        // isDense: !underLinedBorder,
        hintText: hintText,
        suffixText: suffixText,

        hintStyle: TextStyle(
          color: AppColors.grey2,
          fontWeight: FontWeight.bold,
        ),

        suffixIcon: readOnly || textEditingController.text.isEmpty
            ? SizedBox()
            : IconButton(
                alignment: underLinedBorder
                    ? Alignment.topCenter
                    : Alignment.center,
                onPressed: () {
                  textEditingController.clear();
                  provider.recharge(textEditingController);
                  onCleared?.call();
                },
                icon: Icon(AppIcons.cancel, size: 18),
              ),
      ),
    );
  }
}
