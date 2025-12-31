#### 2.14:

* Add optional count limitation of combat texts, when dealing damage to a large number of enemies, it should help prevent lag
* Can optionally sum the same spell damage amount
* More stable damage text layout
* For performance reason, when a nameplate disappears, damage texts which has been layout on it WILL ALSO disappear (originally they will be re-layout on screen)
* Change truncate divider from 1000 to 10000 for chinese

#### 2.13:

* now can always show all damage on-screen
* add min damage filter, ignore no damage (missing, etc.)

#### 2.12:

* optimize extend shape of fill order used by text animation
* add spell blacklist
* pet text color will also be affected if toggle 'Use Damage Type Color', a new pet melee color is being used

#### 2.10:

* change text self-anchor to bottom
* add vertical padding of line
* change draw layer back to background

#### 2.09:

* adapt game version of 10.2.0
* re-design animation
* add an on-screen display, show if you deal damage when you do not select any target or target's nameplate out of screen
  * can change on-screen position, scale and alpha
* if deal damage to one that it's nameplate is out of screen, and your target's nameplate is on-screen, then damage text will be shown on the target's place
* help wanted: russian translation

#### 2.08:

* make crit text a bit bigger, bit quicker up-scale to 2 and slower down-scale to 1.5
* normal text also up-scale from 0.8, move up in exp mode

#### 2.07:

* blizzard fct can be modified no matter this addon being enabled

#### 2.06:

* adapt game version of 9.0.5

#### 2.05:

* adapt game version of 9.0.2

#### 2.04:

* optimize

#### 2.03:

* pkgmeta fix

#### 2.02:

* change file structure for auto packaging
* try to fix nameplate event error

#### 2.01:

* increase text vertical moving animation distance
* text fade-out delay
* change file loading order

#### 2.00:

* new text-fill animation, new sort order, newest text always in center, fewer blinking than classic style, wish you could like it
* new crit animation, crit text is much more impressive now
* multi-types damage color changed to average of each single type color
* because of logic change, remove the limitation of text amount and lines (may add them back in future)
* file structures change
