import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
//
import 'form.dart';
import '../ui/row.dart';
import '../ui/text_error.dart';
import '../ui/section.dart';
import '../page/page.dart';
import '../page/navigation/top_item.dart';
import '../entity/attribute.dart';
import '../entity/collection.dart';
import '../platform/config.dart';
import '../l10n/app_localizations.dart';

class DraftModeFormDropDown<ItemType extends DraftModeEntityCollectionItem, ElementType> extends StatefulWidget {
  final DraftModeEntityCollection<ItemType> items;
  final DraftModeEntityAttribute<ElementType> element;
  final String placeholder;
  final Widget Function(ItemType) renderItem;
  final bool readOnly;
  final String? label;
  final ValueChanged<String>? onSaved;

  const DraftModeFormDropDown({
    super.key,
    required this.items,
    required this.element,
    required this.placeholder,
    required this.renderItem,
    this.readOnly = false,
    this.label,
    this.onSaved
  });

  @override
  State<DraftModeFormDropDown<ItemType, ElementType>> createState() => _DraftModeFormDropDownState<ItemType, ElementType>();
}

class _DraftModeFormDropDownState<ItemType extends DraftModeEntityCollectionItem, ElementType> extends State<DraftModeFormDropDown<ItemType, ElementType>> {
  final _fieldKey = GlobalKey<FormFieldState<ItemType>>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final form = DraftModeFormState.of(context);
      form?.registerField(widget.element, _fieldKey);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = DraftModeFormState.of(context);
    form?.registerProperty(widget.element);
    final DraftModeEntityCollection<ItemType> items = widget.items;
    final value = widget.element.value;

    Future<void> selectItem(FormFieldState<ItemType> field) async {
      final screen = DraftModeFormDropDownScreen<ItemType>(
        selectionTitle: 'selectionTitle',
        items: widget.items,
        element: widget.element,
        renderItem: widget.renderItem,
      );
      final item = await Navigator.of(context).push<ItemType>(
        PlatformConfig.isIOS
            ? CupertinoPageRoute(builder: (_) => screen)
            : MaterialPageRoute(builder: (_) => screen),
      );
      if (item != null) {
        field.didChange(item);
        form?.updateProperty(widget.element, item.getId());
        field.validate();
      }
    }

    return FormField<ItemType>(
      key: _fieldKey,
      initialValue: items.getById(value),
      autovalidateMode: AutovalidateMode.disabled,
      onSaved: (v) {
        final value = v?.getId();
        widget.element.value = value;
        widget.onSaved?.call(value);
      },
      validator: (v) => widget.element.validate(context, form, v?.getId()),
      builder: (field) {
        final Widget content = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: (field.value != null)
              ? widget.renderItem(field.value as ItemType)
              : Text(widget.placeholder),
            ),
            Icon(
              Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoIcons.right_chevron
                  : Icons.arrow_forward_ios,
              size: 16,
              color: CupertinoColors.systemGrey,
            )
          ]
        );
        final Widget child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DraftModeUIRow(
              label: widget.label,
              child: content
            ),
            DraftModeUITextError(
                text: field.errorText,
                visible: true
            ),
          ],
        );

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: !widget.readOnly ? () {
            selectItem(field);
          } : null,
          child: child,
        );
      }
    );
  }
}

class DraftModeFormDropDownScreen<ItemType extends DraftModeEntityCollectionItem> extends StatefulWidget {
  final String selectionTitle;
  final DraftModeEntityCollection<ItemType> items;
  final DraftModeEntityAttribute element;
  final DraftModePageNavigationTopItem? trailing;
  final Widget Function(ItemType) renderItem;

  const DraftModeFormDropDownScreen({
    required this.selectionTitle,
    required this.items,
    required this.element,
    required this.renderItem,
    this.trailing,
    super.key,
  });

  void setItem(BuildContext context, ItemType item) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop<ItemType>(item);
    }
  }

  @override
  State<DraftModeFormDropDownScreen<ItemType>> createState() => _DraftModeFormDropDownScreenState<ItemType>();
}

class _DraftModeFormDropDownScreenState<ItemType extends DraftModeEntityCollectionItem> extends State<DraftModeFormDropDownScreen<ItemType>> {
  @override
  Widget build(BuildContext context) {
    final DraftModeEntityCollection<ItemType> items = widget.items;
    return DraftModePage(
      navigationTitle: widget.selectionTitle,
      topLeadingText: DraftModeLocalizations.of(context)?.navigationBtnCancel ?? 'Cancel',
      topTrailing: widget.trailing != null ? [widget.trailing!] : null,
      body: ListView(
        children: [
          DraftModeUISection(
            children: items.items.map((item) {
              final itemId = item.getId();
              final isSelected = (widget.element.value != null && itemId == widget.element.value);
              final Widget child = CupertinoFormRow(
                padding: EdgeInsets.symmetric(
                    vertical: PlatformConfig.verticalContainerPadding / 2,
                    horizontal: PlatformConfig.horizontalContainerPadding / 2
                ),
                prefix: widget.renderItem(item),
                helper: null,
                child: isSelected
                  ? const Icon(
                      CupertinoIcons.check_mark,
                      size: 22,
                      color: CupertinoColors.activeBlue,
                    )
                  : const SizedBox.shrink()
              );
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => widget.setItem(context, item),
                child: child,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}