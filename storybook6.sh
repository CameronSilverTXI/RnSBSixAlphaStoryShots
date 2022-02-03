#!/bin/bash

yarn add @storybook/react-native@next \
            @react-native-async-storage/async-storage \
            @storybook/addon-ondevice-actions@next \
            @storybook/addon-ondevice-controls@next \
            @storybook/addon-ondevice-backgrounds@next \
            @storybook/addon-ondevice-notes@next \
            @storybook/addon-actions@6.3 \
            @react-native-community/datetimepicker \
            @react-native-community/slider \
            @storybook/addon-controls@6.3

echo "/**
 * Metro configuration for React Native
 * https://github.com/facebook/react-native
 *
 * @format
 */

module.exports = {
  transformer: {
    getTransformOptions: async () => ({
      transform: {
        experimentalImportSupport: false,
        inlineRequires: false,
      },
    }),
  },
  resolver: {
    resolverMainFields: ['sbmodern', 'browser', 'main'],
  },
};" > metro.config.js;


mkdir .storybook;
mkdir components;
echo "module.exports = {
  stories: [
    '../components/**/*.stories.?(ts|tsx|js|jsx)'
  ],
   addons: [
    '@storybook/addon-ondevice-notes',
    '@storybook/addon-ondevice-controls',
    '@storybook/addon-ondevice-backgrounds',
    '@storybook/addon-ondevice-actions',
  ],
};" > .storybook/main.js;

echo "import {withBackgrounds} from '@storybook/addon-ondevice-backgrounds';

export const decorators = [withBackgrounds];
export const parameters = {
  backgrounds: [
    {name: 'plain', value: 'white', default: true},
    {name: 'warm', value: 'hotpink'},
    {name: 'cool', value: 'deepskyblue'},
  ],
};" > .storybook/preview.js;

echo "import { getStorybookUI } from '@storybook/react-native';

import './storybook.requires';

const StorybookUIRoot = getStorybookUI({});

export default StorybookUIRoot;" > .storybook/Storybook.tsx;

echo "import StorybookUIRoot from './.storybook/Storybook';
export { StorybookUIRoot as default };" > App.tsx;

node -e 'const fs = require("fs");
const packageJSON = require("./package.json");
packageJSON.scripts = {
    ...packageJSON.scripts,
    prestart: "sb-rn-get-stories",
    "storybook-watcher": "sb-rn-watcher"
};
fs.writeFile("./package.json", JSON.stringify(packageJSON, null, 2), function writeJSON(err) {
  if (err) return console.log(err);
  console.log(JSON.stringify(packageJSON));
  console.log("writing to " + "./package.json");
});';

cd ios; pod install; cd ..;

mkdir components/Button;
echo "import React from 'react';
import {TouchableOpacity, Text, StyleSheet} from 'react-native';

interface MyButtonProps {
  onPress: () => void;
  text: string;
}

export const MyButton = ({onPress, text}: MyButtonProps) => {
  return (
    <TouchableOpacity style={styles.container} onPress={onPress}>
      <Text style={styles.text}>{text}</Text>
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  container: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    backgroundColor: 'violet',
  },
  text: {color: 'black'},
});
" > components/Button/Button.tsx;

echo "import React from 'react';
import {ComponentStory, ComponentMeta} from '@storybook/react-native';
import {MyButton} from './Button';

const MyButtonMeta: ComponentMeta<typeof MyButton> = {
  title: 'MyButton',
  component: MyButton,
  argTypes: {
    onPress: {action: 'pressed the button'},
  },
  args: {
    text: 'Hello world',
  },
};

export default MyButtonMeta;

type MyButtonStory = ComponentStory<typeof MyButton>;

export const Basic: MyButtonStory = args => <MyButton {...args} />;
" > components/Button/Button.stories.tsx;

yarn sb-rn-get-stories;
