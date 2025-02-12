import 'package:bdaya_flutter_common/bdaya_flutter_common.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:collection/collection.dart';

class BdayaLocalizedStrValueAccessor extends ControlValueAccessor<
    BdayaLocalizedStr, Map<String, TextEditingController>> {
  final cacheMap = <String, TextEditingController>{};
  @override
  Map<String, TextEditingController>? modelToViewValue(
    BdayaLocalizedStr? modelValue,
  ) {
    final backingField = modelValue?.backingField;
    if (backingField == null) return null;

    return backingField.map((key, value) {
      final cacheMapValue = cacheMap[key];
      if (cacheMapValue == null) {
        final v = value ?? '';
        return MapEntry(
          key,
          cacheMap[key] = TextEditingController.fromValue(
            TextEditingValue(
              text: v,
              composing: TextRange.empty,
              selection: TextSelection.collapsed(
                offset: v.length,
                affinity: TextAffinity.downstream,
              ),
            ),
          ),
        );
      } else {
        return MapEntry(
          key,
          cacheMapValue
            ..value = cacheMapValue.value.copyWith(
              text: value ?? '',
            ),
        );
      }
    });
  }

  @override
  BdayaLocalizedStr? viewToModelValue(
    Map<String, TextEditingController>? viewValue,
  ) {
    if (viewValue == null) return null;
    return BdayaLocalizedStr.fromBackingField(
      viewValue.map(
        (key, value) => MapEntry(
          key,
          value.text,
        ),
      ),
      copy: false,
    );
  }
}

typedef BdayaLocaliedOnChanged = void Function(String newValue);
typedef BdayaTextFieldBuilderFunction = Widget Function(
  BuildContext context,
  String locale,
  TextEditingController? controller,
  BdayaLocaliedOnChanged onChanged,
  TextDirection textDirection,
  InputDecoration decoration,
);

class BdayaReactiveLocalizedFormField extends ReactiveFormField<
    BdayaLocalizedStr, Map<String, TextEditingController>> {
  BdayaReactiveLocalizedFormField({
    String? formControlName,
    FormControl<BdayaLocalizedStr>? formControl,
    String? label,
    ShowErrorsFunction<BdayaLocalizedStr>? showErrors,
    Map<String, ValidationMessageFunction>? validationMessages,
    List<String>? locales,
    Set<String>? rtlLocales,
    required Widget Function(
      BuildContext context,
      List<Widget> children,
    )
        parentBuilder,
    BdayaTextFieldBuilderFunction? textFieldBuilder,
    ControlValueAccessor<BdayaLocalizedStr, Map<String, TextEditingController>>?
        valueAccessor,
    Key? key,
  }) : super(
          formControl: formControl,
          formControlName: formControlName,
          key: key,
          showErrors: showErrors,
          validationMessages: validationMessages,
          valueAccessor: valueAccessor ?? BdayaLocalizedStrValueAccessor(),
          builder: (field) {
            final value = field.value ?? {};
            final errors = field.control.errors;
            final errorsPerLocale = <String, List<String>>{};
            for (final errorEntry in errors.entries) {
              final error = errorEntry.key;
              final errorDesc = errorEntry.value;
              if (errorDesc is Set<String>) {
                for (var locale in errorDesc) {
                  final localeExistingErrors = errorsPerLocale[locale] ??= [];
                  localeExistingErrors.add(error);
                }
              }
            }
            locales ??= field.context
                .findAncestorWidgetOfExactType<WidgetsApp>()
                ?.supportedLocales
                .map((e) => e.toLanguageTag())
                .toList();
            rtlLocales ??= BdayaLocalizedStr.rtlLocales;
            final children = locales!.map((locale) {
              final fieldController = value[locale];
              final isRtl = rtlLocales!.any(locale.startsWith);
              final textDirection =
                  isRtl ? TextDirection.rtl : TextDirection.ltr;
              void onChanged(String newValue) {
                final changedController =
                    value[locale] ?? TextEditingController(text: newValue);
                final newMap = Map.of(value);
                newMap[locale] = changedController;
                field.control.markAsTouched();
                field.didChange(newMap);
              }

//?.call(field.control)

// field.control.errors
              // field.errorText;
              final messages = field.widget.validationMessages ??
                  ReactiveFormConfig.of(field.context)?.validationMessages ??
                  {};
              final errorsForCurrentLocale = errorsPerLocale[locale];
              final error = errorsForCurrentLocale?.firstOrNull;
              final errorText =
                  error != null ? messages[error]?.call(locale) ?? error : null;

              final defaultDecoration = InputDecoration(
                labelText: '$label [$locale]',
                errorText: (field.widget.showErrors?.call(field.control) ??
                        (field.control.invalid && field.control.touched))
                    ? errorText
                    : null,
              ).applyDefaults(Theme.of(field.context).inputDecorationTheme);
              return Directionality(
                textDirection: textDirection,
                child: textFieldBuilder?.call(
                      field.context,
                      locale,
                      fieldController,
                      onChanged,
                      textDirection,
                      defaultDecoration,
                    ) ??
                    TextField(
                      textDirection: textDirection,
                      decoration: defaultDecoration,
                      controller: fieldController,
                      onChanged: onChanged,
                    ),
              );
            }).toList();
            return parentBuilder(field.context, children);
          },
        );
}

class BdayaLocalizedStrRequiredValidator extends Validator<BdayaLocalizedStr> {
  @override
  Map<String, dynamic>? validate(AbstractControl<BdayaLocalizedStr> control) {
    final value = control.value;
    if (value == null) {
      return <String, dynamic>{ValidationMessage.required: true};
    } else {
      final backingField = value.backingField;
      final errorLocales = <String>{};
      for (var valueEntry in backingField.entries) {
        final locale = valueEntry.key;
        final entryValue = valueEntry.value;
        if (entryValue?.trim().isValid != true) {
          errorLocales.add(locale);
        }
      }
      return {
        if (errorLocales.isNotEmpty) ValidationMessage.required: errorLocales,
      };
    }
  }
}
