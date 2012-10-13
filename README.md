# architecture-js [![Build Status](https://secure.travis-ci.org/daytonn/architecture-js.png)](http://travis-ci.org/daytonn/architecture-js)

[Documentation](http://daytonn.github.com/architecture-js/)

##About
ArchitectureJS is javascript build tool that helps you create and manage large-scale javascript applications with one simple command line interface. The goal of Architecturejs is to take the headache out of managing complex javascript code. ArchitectureJS is really a few tools rolled into one that provides a simple but flexible workflow:

* Project-specific configuration to manage defaults and dependencies
* JavaScript Compiler (Sprockets 1.0.2)
* JavaScript Compression (JSMin)
* Scaffold generation using editable templates
* Realtime file monitoring utility to compile your application while you code

## Installation
Requires ruby version 1.9 or higher. Using rubygems:

    gem install architecture-js

## Getting Started
ArchitectureJS comes with a small command line utility named `architect` to manage your architecture projects. To be sure architecture-js is installed correctly, type this command:

    architect -h
 
If `architect` is installed, you should see the help menu. There are only a few simple commands: create, compile, and watch. These commands are all you need to manage your architecture projects.

To create an architect application use the create command (where "myapp" is the name of _your_ application)

    architect create MyApp

This will create the default project scaffold:

    /lib
    /src/
        myapp.js
    myapp.blueprint

<a id="configuration"></a>
## Default Configurtaion
The `myapp.blueprint` file is the configuration file for your project. The default config file looks something like this

	blueprint: default
	src_dir: src
	build_dir: lib
	asset_root: ../
	output: compressed
	template_dir: templates
	template_namespace: templates
	name: MyApp

### blueprint
The project's `blueprint` is the framework your application is based on. The default blueprint is `default` which is a bare bones layout useful for simple javascript libraries (ie. underscore.js, backbone.js). Other blueprints can be used to support any application architecture you prefer. Blueprints are simple `Ruby` classes which extend the basic blueprint. Custom blueprints can have unique properties and scaffolding, but all ArchitectureJS projects will share this same core properties contained in this default blueprint (even if they are not used).

### src_dir
The `src_dir` is the target path or paths where `architect` will search for files to be compiled. By default the `src_dir` is usually a single directory represented as a string:

    src_dir: src

However the src_dir can be multiple paths. To search for source files in three directories named "classes", "widgets", and "plugins", `src_dir` would be an array:

    src_dir: [classes, widgets, plugins]


Any files in these three directories would be compiled into the build directory, including their requirements.

### build_dir
The `build_dir` is where all source files will be compiled.

### asset_root
The `asset_root` is where stylesheet and image assets will be installed by the `//= provide` directive. By default the `asset_root` is the project root. Stylesheets and images will be placed in css and images directories respectively.

<a id="output"></a>
### output
The `output` determines whether the compiled javascript will be `compressed` or `expanded`, which are the two possible values. The JSMin engine is used for compression.

### name
The `name` is the name of your architecture project. The name value can be used by the blueprint in a variety of ways. By default the name is used to create the main application file in the /src directory (in lowercase).

<a id="compilation"></a>
## Compilation

### compile
You can compile your architecture project manually with the compile command:

    architect compile

This will get the requirements of every file in your `src_dir`(s) and compile them into your `build_dir` using the settings found in the `.blueprint` file in the current directory.

<a id="watch"></a>
### watch

Having to do this manually every time you change a file and want to see it in your browser is a pain in the ass. Using the `watch` command is probably the only way you'll want to develop an ArchitectureJS project:

    architect watch

This will watch the project directory and compile the project every time a file changes. Even rather large applications compile instantly, so you can work without ever having to wait for it to build.

<a id="templates"></a>
## Templates

The ArchitectureJS templating system is designed to let you organize your javascript templates on the file system however you like. ArchitectureJS uses the ruby-ejs gem to automatically compile your template files into your application.

By default, ArchitectureJS searches for templates in the blueprint's template_dir. Any file with a .jst extension will be compiled into your application as a [JST](http://code.google.com/p/trimpath/wiki/JavaScriptTemplates) template function under your blueprint's `template_namespace`. For example with the following project structure:

* lib
* myapp.blueprint
* src
	* myapp.js
* templates
	* my_template.jst
	* another_template.jst

Given the following configuration, when the application is compiled, the templates will be compiled into the build_dir (/lib) in a file named templates.js:

blueprint: default
src_dir: src
build_dir: lib
asset_root: ../
output: compressed
template_dir: templates
template_namespace: templates
name: MyApp

ArchitectureJS will create a template file like this:

```js
	MyApp.templates = {
	    "my_template": /* compiled ejs template function */,
	    "another_template": /* compiled ejs template function */
	};
```

You can then include the `[build_dir]/templates.js` file directly in your html or use `//= require` in your application file. This allows you to treat templates as individual files, while seamlessly providing template methods to render your templates within your application.


<a id="sprockets"></a>
## Sprockets
ArchitectureJS uses Sprockets under the hood to enable using a file system layout that corresponds to your javascript architecture. This is the heart of the ArchitectureJS system. In addition to concatenating scripts, Sprockets can also include stylesheet and image assets used by scripts. It has a basic syntax using javascript comments, gracefully enhancing plain old vanilla javascript.

Sprockets takes any number of source files and preprocesses them line-by-line in order to build a single concatenation. Specially formatted lines act as directives to the Sprockets preprocessor, telling it to require the contents of another file or library first or to provide a set of asset files to the document root. Sprockets attempts to fulfill required dependencies by searching a set of directories called the load path.

### Comments
Use single-line (`//`) comments in JavaScript source files for comments that don’t need to appear in the resulting concatenated output. Use multiple-line (`/* ... */`) comments for comments that should appear in the resulting concatenated output, like copyright notices or descriptive headers.
Comments beginning with `//=` are treated by Sprockets as directives. Sprockets currently understands two directives, `require` and `provide`.

### //= require
Use the `require` directive to tell Sprockets that another JavaScript source file should be inserted into the concatenation before continuing to preprocess the current source file. If the specified source file has already been required, Sprockets ignores the directive.

The format of a `require` directive determines how Sprockets looks for the dependent source file. If you place the name of the source file in angle brackets:

```js
    //= require <prototype>
```
Sprockets will search your load path, in order, for a file named `prototype.js`, and begin preprocessing the first match it finds. (An error will be raised if a matching file can’t be found.) If you place the name of the source file in quotes:

```js
    //= require "date_helper"
```

Sprockets will not search the load path, but will instead look for a file named `date_helper.js` in the same directory as the current source file. In general, it is a good idea to use quotes to refer to related files, and angle brackets to refer to packages, libraries, or third-party code that may live in a different location.

You can refer to files in subdirectories with the `require` directive. For example:

```js
    //= require <behavior/hover_observer>
```

Sprockets will search the load path for a file named `hover_observer.js` in a directory named `behavior`.

### //= provide
Sometimes it is necessary to include associated stylesheets, images, or even HTML files with a JavaScript plugin. Sprockets lets you specify that a JavaScript source file depends on a set of assets, and offers a routine for copying all dependent assets into the document root.

The `provide` directive tells Sprockets that the current source file depends on the set of assets in the named directory. For example, say you have a plugin with the following directory structure:

    plugins/color_picker/assets/images/color_picker/arrow.png
    plugins/color_picker/assets/images/color_picker/circle.png
    plugins/color_picker/assets/images/color_picker/hue.png
    plugins/color_picker/assets/images/color_picker/saturation_and_brightness.png
    plugins/color_picker/assets/stylesheets/color_picker.css
    plugins/color_picker/src/color.js
    plugins/color_picker/src/color_picker.js

Assume `plugins/color_picker/src/` is in your Sprockets load path. `plugins/color_picker/src/color_picker.js` might look like this:

```js
    //= require "color"
    //= provide "../assets"
```

When `<color_picker>` is required in your application, its `provide` directive will tell Sprockets that all files in the `plugins/color_picker/assets/` directory should be copied into the web project’s root.

## ArchitectureJS/Sprockets Integration
ArchitectureJS automatically sets up Sprockets' `load_path` to include your project root directory and your internal repository. This gives every application you create with ArchitectureJS access to a central library of scripts that you maintain with the `//= require` directive. For example, if you have the jQuery library in your repository you could include it in you application with a simple:

```js
    //= require <jquery-1.7.1>
``` 

##Contributing to architecture.js
 
* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

##Copyright

Copyright (c) 2011 Dayton Nolan. See LICENSE.txt for
further details.