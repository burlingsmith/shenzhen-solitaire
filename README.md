# Shenzen Solitaire
Standalone Shenzen solitaire written in Elm

## Modules

### Generic

These are the module directly in the src directory. They are unspecialized.

- **Main**: Router for messages and so on

- **Grid**: Two-dimensional array implementation

- **Field**: Easy-to-use graphics module. Fields are composed of evenly-spaced
nodes. Each node contains its position within the field, a collage message,
and any data assigned to it.

### Shenzen

Modules more specific to shenzen solitaire.

- **Card**: Representation of a single shenzen card

- **Deck**: Representation for collections of shenzen cards

- **Board**: Representation of the shenzen tabletop layout

- **Solitaire**: Shenzen Solitaire's game logic
