# DI Dealers CLI
Lists dev and live URLs for DI sites base on slug with autocomplete

# Setup
```
// Install node dependencies
npm install

// Register the cli keyword in bash
npm link

// We need to add the auto complete package to your bash
// This will prompt you to select what type of bash you are using
// If you're not using anything special, select bash
did -i
```

# Usage

## Update (-u --update)
- The update command with pull the most current list of dealers, this should be ran ever once in a while

```
did -u
```

## List (-l --list)
Will list the dev url and live url for a given slug

```
did -l forddemo
```

# Autocomplete Example

If you enter
```
did -l ford
```
and hit tab you should get auto complete for slugs that begin with `ford`