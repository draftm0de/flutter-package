import 'package:draftmode/platform.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../page/navigation/top_item.dart';
import '../page/page.dart';
import '../ui/row.dart';
import '../ui/section.dart';
import '../ui/error_text.dart';
import '../entity/interface.dart';
import 'form.dart';
import 'list.dart';

/// Draftmode-aware dropdown field that navigates to a platform-appropriate
/// selection screen. Values propagate through the associated
/// [DraftModeEntityAttributeInterface] so validators and persistence behave the same as
/// other form controls.
class DraftModeFormDropDown<
  ItemType extends DraftModeEntityInterface<ElementType>,
  ElementType
>
    extends StatefulWidget {
  final List<ItemType> items;
  final DraftModeEntityAttributeInterface<ElementType> attribute;
  final String placeholder;
  final Widget Function(ItemType) renderItem;
  final DraftModeFormListItemWidgetBuilder<ItemType>? itemBuilder;
  final bool readOnly;
  final String? label;
  final String? selectionTitle;
  final ValueChanged<ElementType?>? onSaved;

  const DraftModeFormDropDown({
    super.key,
    required this.items,
    required this.attribute,
    required this.placeholder,
    required this.renderItem,
    this.itemBuilder,
    this.readOnly = false,
    this.label,
    this.selectionTitle,
    this.onSaved,
  });

  @override
  State<DraftModeFormDropDown<ItemType, ElementType>> createState() =>
      _DraftModeFormDropDownState<ItemType, ElementType>();
}

class _DraftModeFormDropDownState<
  ItemType extends DraftModeEntityInterface<ElementType>,
  ElementType
>
    extends State<DraftModeFormDropDown<ItemType, ElementType>> {
  final _fieldKey = GlobalKey<FormFieldState<ElementType>>();
  DraftModeFormState? _form;
  bool _fieldRegistered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncFormAssociation();
    });
  }

  void _syncFormAssociation() {
    final candidate = DraftModeFormState.of(context);
    if (!identical(candidate, _form)) {
      _detachFromForm();
      _form = candidate;
    }
    final form = _form;
    if (form != null && !_fieldRegistered) {
      form.registerField(widget.attribute, _fieldKey);
      _fieldRegistered = true;
    }
  }

  void _detachFromForm({
    DraftModeEntityAttributeInterface<ElementType>? attribute,
  }) {
    if (_form == null || !_fieldRegistered) return;
    _form?.unregisterField(attribute ?? widget.attribute, _fieldKey);
    _fieldRegistered = false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFormAssociation();
  }

  @override
  void didUpdateWidget(
    covariant DraftModeFormDropDown<ItemType, ElementType> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.attribute, widget.attribute)) {
      _detachFromForm(attribute: oldWidget.attribute);
      _syncFormAssociation();
    }
  }

  @override
  void dispose() {
    _detachFromForm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _syncFormAssociation();
    _form?.registerProperty(widget.attribute);
    final items = widget.items;
    final selectedId = widget.attribute.value;

    Future<void> selectItem(FormFieldState<ElementType> field) async {
      final screen = DraftModeFormDropDownScreen<ItemType, ElementType>(
        selectionTitle:
            widget.selectionTitle ?? widget.label ?? widget.placeholder,
        items: widget.items,
        selectedItem: widget.attribute,
        renderItem: widget.renderItem,
        itemBuilder: widget.itemBuilder,
      );
      final item = await Navigator.of(context).push<ItemType>(
        PlatformConfig.isIOS
            ? CupertinoPageRoute(builder: (_) => screen)
            : MaterialPageRoute(builder: (_) => screen),
      );
      if (item == null) return;

      final id = item.getId();
      field.didChange(id);
      _form?.updateProperty(widget.attribute, id);
      field.validate();
    }

    ItemType? getItemById(ElementType? key) {
      if (key == null) return null;
      for (final item in items) {
        if (item.getId() == key) return item;
      }
      return null;
    }

    return FormField<ElementType>(
      key: _fieldKey,
      initialValue: selectedId,
      autovalidateMode: AutovalidateMode.disabled,
      onSaved: (value) {
        widget.attribute.value = value;
        widget.onSaved?.call(value);
      },
      validator: (value) => widget.attribute.validate(context, _form, value),
      builder: (field) {
        final enableValidation = _form?.enableValidation ?? false;
        final showError = enableValidation && field.hasError;
        final selectedItem = getItemById(field.value);

        final content = selectedItem != null
            ? widget.renderItem(selectedItem)
            : Text(widget.placeholder);
        final child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DraftModeUIRow(label: widget.label, child: content),
            DraftModeUIErrorText(text: field.errorText, visible: showError),
          ],
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.readOnly ? null : () => selectItem(field),
          child: child,
        );
      },
    );
  }
}

/// Selection sheet pushed by [DraftModeFormDropDown]. Extracted so navigation
/// follows the existing Draftmode page scaffolding and localisation helpers.
class DraftModeFormDropDownScreen<
  ItemType extends DraftModeEntityInterface<ElementType>,
  ElementType
>
    extends StatefulWidget {
  final String selectionTitle;
  final List<ItemType> items;
  final DraftModeEntityAttributeInterface<ElementType> selectedItem;
  final DraftModePageNavigationTopItem? trailing;
  final Widget Function(ItemType) renderItem;
  final DraftModeFormListItemWidgetBuilder<ItemType>? itemBuilder;

  DraftModeFormDropDownScreen({
    required this.selectionTitle,
    required this.items,
    required this.selectedItem,
    required this.renderItem,
    this.itemBuilder,
    this.trailing,
    super.key,
  });

  void setItem(BuildContext context, ItemType item) {
    if (!Navigator.of(context).canPop()) return;
    Navigator.of(context).pop<ItemType>(item);
  }

  @override
  State<DraftModeFormDropDownScreen<ItemType, ElementType>> createState() =>
      _DraftModeFormDropDownScreenState<ItemType, ElementType>();
}

class _DraftModeFormDropDownScreenState<
  ItemType extends DraftModeEntityInterface<ElementType>,
  ElementType
>
    extends State<DraftModeFormDropDownScreen<ItemType, ElementType>> {
  @override
  Widget build(BuildContext context) {
    final items = widget.items;

    Widget buildListView() {
      return ListView(
        children: [
          DraftModeUISection(
            children: items.map((item) {
              final itemId = item.getId();
              final isSelected =
                  widget.selectedItem.value != null &&
                  itemId == widget.selectedItem.value;
              final child = CupertinoFormRow(
                padding: EdgeInsets.symmetric(
                  vertical: DraftModeStylePadding.primary / 2,
                  horizontal: DraftModeStylePadding.primary / 2,
                ),
                prefix: widget.renderItem(item),
                helper: null,
                child: isSelected
                    ? Icon(
                        PlatformButtons.save,
                        size: 22,
                        color: DraftModeStyleColorTint.primary.background,
                      )
                    : const SizedBox.shrink(),
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.setItem(context, item),
                child: child,
              );
            }).toList(),
          ),
        ],
      );
    }

    ItemType? resolveSelectedItem() {
      final selectedId = widget.selectedItem.value;
      if (selectedId == null) return null;
      for (final item in items) {
        if (item.getId() == selectedId) {
          return item;
        }
      }
      return null;
    }

    Widget buildFormList() {
      final selectedItem = resolveSelectedItem();
      return DraftModeFormList<ItemType, ElementType>(
        isPending: false,
        items: items,
        selectedItem: selectedItem,
        itemBuilder: (context, item, isSelected) =>
            widget.itemBuilder!(context, item, isSelected),
        onTap: (item) => widget.setItem(context, item),
      );
    }

    final bool hasItemBuilder = widget.itemBuilder != null;
    final body = hasItemBuilder ? buildFormList() : buildListView();

    return DraftModePage(
      navigationTitle: widget.selectionTitle,
      topTrailing: widget.trailing != null ? [widget.trailing!] : null,
      body: body,
    );
  }
}
