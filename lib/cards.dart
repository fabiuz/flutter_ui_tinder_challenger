import 'dart:math';

import 'package:flutter/material.dart';
import './profiles.dart';
import 'package:fluttery/layout.dart';
import './photos.dart';
import './matches.dart';

class CardStack extends StatefulWidget {
  final MatchEngine matchEngine;

  CardStack({
    this.matchEngine,
  });

  CardStackState createState() => CardStackState();
}

class CardStackState extends State<CardStack> {
  Key _frontCard;
  DateMatch _currentMatch;
  double _nextCardScale = 0.9;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    widget.matchEngine.addListener(_onMatchEngineChange);

    _currentMatch = widget.matchEngine.currentMatch;
    _currentMatch.addListener(_onMatchChange);

    _frontCard = new Key(_currentMatch.profile.name);
  }

  @override
  void didUpdateWidget(CardStack oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (widget.matchEngine != oldWidget.matchEngine) {
      oldWidget.matchEngine.removeListener(_onMatchEngineChange);
      widget.matchEngine.addListener(_onMatchEngineChange);

      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }
      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }
    }
  }

  @override
  void dispose() {
    if (_currentMatch != null) {
      _currentMatch.removeListener(_onMatchChange);
    }

    widget.matchEngine.removeListener(_onMatchEngineChange);

    super.dispose();
  }

  void _onMatchEngineChange() {
    setState(() {
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }
      _currentMatch = widget.matchEngine.currentMatch;
      if (_currentMatch != null) {
        _currentMatch.removeListener(_onMatchChange);
      }

      _frontCard = new Key(_currentMatch.profile.name);
    });
  }

  void _onMatchChange() {
    setState(() {
      /* current match may have changed state, re-render */
    });
  }

  Widget _buildBackCard() {
    return Transform(
      transform: Matrix4.identity()..scale(_nextCardScale, _nextCardScale),
      alignment: Alignment.center,
      child: ProfileCard(
        profile: widget.matchEngine.nextMatch.profile,
      ),
    );
  }

  Widget _buildFrontCard() {
    return ProfileCard(
      key: _frontCard,
      profile: widget.matchEngine.currentMatch.profile,
    );
  }

  SlideDirection _desiredSlideOutDirection() {
    switch (widget.matchEngine.currentMatch.decision) {
      case Decision.nope:
        return SlideDirection.left;
      case Decision.like:
        return SlideDirection.right;
      case Decision.superLike:
        return SlideDirection.up;
      default:
        return null;
    }
  }

  void _onSlideUpdate(double distance) {
    setState(() {
      _nextCardScale = 0.9 + (0.1 * (distance / 100.0)).clamp(0.0, 0.1);
    });
  }

  void _onSlideOutComplete(SlideDirection direction) {
    DateMatch currentMatch = widget.matchEngine.currentMatch;

    switch (direction) {
      case SlideDirection.left:
        currentMatch.nope();
        break;
      case SlideDirection.right:
        currentMatch.like();
        break;
      case SlideDirection.up:
        currentMatch.superLike();
    }

    widget.matchEngine.cycleMatch();
  }

  @override
  Widget build(BuildContext context) {
    print('Desired slide direction: ${_desiredSlideOutDirection()}');

    return Stack(
      children: <Widget>[
        DraggableCard(
          card: _buildBackCard(),
          isDraggable: false,
        ),
        DraggableCard(
          card: _buildFrontCard(),
          // card,
          slideTo: _desiredSlideOutDirection(),
          onSlideUpdate: _onSlideUpdate,
          onSlideOutComplete: _onSlideOutComplete,
        ),
      ],
    );
  }
}

enum SlideDirection { left, right, up }

class DraggableCard extends StatefulWidget {
  final Widget card;
  final bool isDraggable;
  final SlideDirection slideTo;
  final Function(double distance) onSlideUpdate;
  final Function(SlideDirection) onSlideOutComplete;

  DraggableCard({
    this.card,
    this.isDraggable = true,
    this.slideTo,
    this.onSlideUpdate,
    this.onSlideOutComplete,
  });

  DraggableCardState createState() => DraggableCardState();
}

class DraggableCardState extends State<DraggableCard>
    with TickerProviderStateMixin {
  Decision decision;
  GlobalKey profileCardKey = new GlobalKey(debugLabel: 'profile_card_key');

  Offset cardOffset = const Offset(0.0, 0.0);
  Offset dragStart;
  Offset dragPosition;
  Offset slideBackStart;
  SlideDirection slideOutDirection;
  AnimationController slideBackAnimation;
  Tween<Offset> slideOutTween;
  AnimationController slideOutAnimation;

  void initState() {
    super.initState();
    slideBackAnimation = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )
      ..addListener(
        () => setState(
              () {
                cardOffset = Offset.lerp(
                  slideBackStart,
                  const Offset(0.0, 0.0),
                  Curves.elasticOut.transform(slideBackAnimation.value),
                );

                if (null != widget.onSlideUpdate) {
                  widget.onSlideUpdate(cardOffset.distance);
                }
              },
            ),
      )
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideBackStart = null;
            dragPosition = null;
          });
        }
      });

    slideOutAnimation = new AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )
      ..addListener(() {
        setState(() {
          cardOffset = slideOutTween.evaluate(slideOutAnimation);

          if (null != widget.onSlideUpdate) {
            widget.onSlideUpdate(cardOffset.distance);
          }
        });
      })
      ..addStatusListener((AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            dragStart = null;
            slideOutTween = null;
            dragPosition = null;
            cardOffset = const Offset(0.0, 0.0);

            //widget.match.reset();
            if (widget.onSlideOutComplete != null) {
              widget.onSlideOutComplete(slideOutDirection);
            }
          });
        }
      });

    //widget.match.addListener(_onMatchChange);
    //decision = widget.match.decision;
  }

  @override
  void dispose() {
    slideBackAnimation.dispose();

    super.dispose();
  }

  // void _onMatchChange() {
  //   if (widget.match.decision != decision) {
  //     switch (widget.match.decision) {
  //       case Decision.nope:
  //         _slideLeft();
  //         break;

  //       case Decision.like:
  //         _slideRight();
  //         break;

  //       case Decision.superLike:
  //         _slideUp();
  //         break;

  //       default:
  //         break;
  //     }
  //   }

  //   decision = widget.match.decision;
  // }

  @override
  void didUpdateWidget(DraggableCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.key != oldWidget.card.key) {
      cardOffset = const Offset(0.0, 0.0);
    }

    if (oldWidget.slideTo == null && widget.slideTo != null) {
      switch (widget.slideTo) {
        case SlideDirection.left:
          _slideLeft();
          break;
        case SlideDirection.right:
          _slideRight();
          break;
        case SlideDirection.up:
          _slideUp();
          break;
      }
    }
  }

  Offset _chooseRandomDragStart() {
    final cardContext = profileCardKey.currentContext;
    final cardTopLeft =
        (cardContext.findRenderObject() as RenderBox).localToGlobal(
      const Offset(0.0, 0.0),
    );
    final dragStartY =
        cardContext.size.height * (Random().nextDouble() < 0.5 ? 0.25 : 0.75) +
            cardTopLeft.dy;
    return Offset(cardContext.size.width / 2 + cardTopLeft.dx, dragStartY);
  }

  void _slideLeft() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
      begin: const Offset(0.0, 0.0),
      end: new Offset(-2 * screenWidth, 0.0),
    );
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideRight() async {
    final screenWidth = context.size.width;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
      begin: const Offset(0.0, 0.0),
      end: new Offset(2 * screenWidth, 0.0),
    );
    slideOutAnimation.forward(from: 0.0);
  }

  void _slideUp() async {
    final screenHeight = context.size.height;
    dragStart = _chooseRandomDragStart();
    slideOutTween = new Tween(
      begin: const Offset(0.0, 0.0),
      end: new Offset(0.0, -2 * screenHeight),
    );
    slideOutAnimation.forward(from: 0.0);
  }

  void _onPanStart(DragStartDetails details) {
    dragStart = details.globalPosition;

    if (slideBackAnimation.isAnimating) {
      slideBackAnimation.stop(canceled: true);
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      dragPosition = details.globalPosition;
      cardOffset = dragPosition - dragStart;

      if (null != widget.onSlideUpdate) {
        widget.onSlideUpdate(cardOffset.distance);
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final dragVector = cardOffset / cardOffset.distance;
    final isInLeftRegion = (cardOffset.dx / context.size.width) < -0.45;
    final isInRightRegion = (cardOffset.dx / context.size.width) > 0.45;
    final isInTopRegion = (cardOffset.dy / context.size.height) < -0.40;

    print('isInNopeRegion: $isInLeftRegion');
    print('isInLikeRegion: $isInRightRegion');

    setState(() {
      if (isInLeftRegion || isInRightRegion) {
        slideOutTween = new Tween(
            begin: cardOffset, end: dragVector * (2 * context.size.width));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection =
            isInLeftRegion ? SlideDirection.left : SlideDirection.right;
      } else if (isInTopRegion) {
        slideOutTween = Tween(
            begin: cardOffset, end: dragVector * (2 * context.size.height));
        slideOutAnimation.forward(from: 0.0);

        slideOutDirection = SlideDirection.up;
      } else {
        slideBackStart = cardOffset;
        slideBackAnimation.forward(from: 0.0);
      }
    });

    slideBackStart = cardOffset;
    slideBackAnimation.forward(from: 0.0);
  }

  double _rotation(Rect dragBounds) {
    if (dragStart != null) {
      final rotationCornerMultiplier =
          dragStart.dy >= dragBounds.top + (dragBounds.height / 2) ? -1 : 1;
      return (pi / 8) *
          (cardOffset.dx / dragBounds.width) *
          rotationCornerMultiplier;
    } else {
      return 0.0;
    }
  }

  Offset _rotationOrigin(Rect dragBounds) {
    if (dragStart != null) {
      return dragStart - dragBounds.topLeft;
    } else {
      return const Offset(0.0, 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnchoredOverlay(
      showOverlay: true,
      child: Center(),
      overlayBuilder: (
        BuildContext context,
        Rect anchorBounds,
        Offset anchor,
      ) {
        return CenterAbout(
          position: anchor,
          child: Transform(
            transform:
                Matrix4.translationValues(cardOffset.dx, cardOffset.dy, 0.0)
                  ..rotateZ(_rotation(anchorBounds)),
            origin: _rotationOrigin(anchorBounds),
            child: Container(
              key: profileCardKey,
              width: anchorBounds.width,
              height: anchorBounds.height,
              padding: const EdgeInsets.all(16.0),
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: widget.card,
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileCard extends StatefulWidget {
  final Profile profile;

  ProfileCard({
    Key key,
    this.profile,
  }) : super(key: key);

  ProfileCardState createState() => ProfileCardState();
}

class ProfileCardState extends State<ProfileCard> {
  Widget _buildBackground() {
    return PhotoBrowser(
      photoAssetPaths: widget.profile.photos,
      visiblePhotoIndex: 1,
    );
  }

  Widget _buildProfileSynopsys() {
    return Positioned(
      left: 0.0,
      right: 0.0,
      bottom: 0.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.8),
              ]),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    widget.profile.name,
                    style: TextStyle(color: Colors.white, fontSize: 24.0),
                  ),
                  Text(
                    widget.profile.bio,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.info,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
              color: const Color(0x11000000),
              blurRadius: 5.0,
              spreadRadius: 2.0),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _buildBackground(),
              _buildProfileSynopsys(),
            ],
          ),
        ),
      ),
    );
  }
}
