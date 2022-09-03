library pic_stack;

import 'package:flutter/material.dart';

enum StackStyle {
  card(0.1),
  zigZag(0.15);

  final double value;
  const StackStyle(this.value);
}

class ImageStack extends StatefulWidget {
  final List<String> imageCollection;
  final StackStyle stackStyle;
  final double frameWidth;
  final double frameHeight;
  final Color frameBorderColor;
  final double frameBorderWidth;
  final BorderStyle frameBorderStyle;

  const ImageStack(
      {Key? key,
      required this.imageCollection,
      required this.stackStyle,
      this.frameWidth = 250,
      this.frameHeight = 250,
      this.frameBorderColor = Colors.white,
      this.frameBorderWidth = 0.0,
      this.frameBorderStyle = BorderStyle.none})
      : super(key: key);

  @override
  State<ImageStack> createState() => _ImageStakeState();
}

class _ImageStakeState extends State<ImageStack> {
  //bool switchToPhotoRollView = false;
  Widget? renderingWidget;

  double calculateRotationAngle(int itemKey) {
    switch (widget.stackStyle) {
      case StackStyle.card:
        return itemKey * widget.stackStyle.value;
      case StackStyle.zigZag:
        return itemKey % 2 == 0
            ? itemKey * widget.stackStyle.value
            : itemKey * -widget.stackStyle.value;
      default:
        return 0.1;
    }
  }

  Widget imageHolder(String imageUrl, double rotationAngle) {
    return Transform.rotate(
      angle: rotationAngle,
      child: Opacity(
        opacity: 1.0,
        child: Container(
            width: widget.frameWidth,
            height: widget.frameHeight,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              border: Border.all(
                  color: widget.frameBorderColor,
                  width: widget.frameBorderWidth,
                  style: widget.frameBorderStyle),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.network(imageUrl)),
      ),
    );
  }

  Widget imageStack({required Key key}) {
    return GestureDetector(
      onTap: () => {
        setState(() {
          renderingWidget = imageRoll(key: const ValueKey(2));
        }),
      },
      child: Stack(
          key: key,
          children: widget.imageCollection
              .asMap()
              .entries
              .map((item) => imageHolder(
                    item.value,
                    calculateRotationAngle(item.key),
                  ))
              .toList()),
    );
  }

  Widget imageRoll({required Key key}) {
    double differenceInDrag = 0.0;
    return GestureDetector(
      onVerticalDragStart: (details) =>
          differenceInDrag = details.globalPosition.dy,
      onVerticalDragUpdate: (details) => {
        if (differenceInDrag < details.globalPosition.dy &&
            details.globalPosition.dy - differenceInDrag > 50.0)
          {
            setState(() {
              renderingWidget = imageStack(key: const ValueKey(1));
            }),
          }
      },
      child: Center(
        child: SizedBox(
          height: 250,
          child: ListView.builder(
            itemCount: widget.imageCollection.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: ((context, index) => Container(
                  height: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                  child: Image.network(
                    widget.imageCollection[
                        (widget.imageCollection.length - 1) - index],
                    fit: BoxFit.cover,
                  ),
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
        duration: const Duration(seconds: 1),
        // transitionBuilder: (Widget child, Animation<double> animation) {
        //   return ScaleTransition(scale: animation, child: child);
        // },
        child: renderingWidget ?? imageStack(key: const ValueKey(1)));
  }
}
