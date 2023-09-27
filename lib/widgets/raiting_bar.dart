import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBarWidget extends StatefulWidget {
  final Function(double) onRatingChanged;
  final double initialRating;

  RatingBarWidget({
    this.onRatingChanged,
    this.initialRating = 0.0,
  });

  @override
  _RatingBarWidgetState createState() => _RatingBarWidgetState();
}

class _RatingBarWidgetState extends State<RatingBarWidget> {
  double _rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      initialRating: _rating,
      minRating: 0.0,
      maxRating: 5.0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 60.0,
      itemBuilder: (context, index) {
        return Icon(
          index < _rating.floor() ? Icons.star : Icons.star_border,
          color: index < _rating.floor()
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.secondary,
        );
      },
      onRatingUpdate: (rating) {
        setState(() {
          _rating = rating;
        });
        widget.onRatingChanged(rating);
      },
      unratedColor: Theme.of(context).primaryColor,
    );
  }
}
