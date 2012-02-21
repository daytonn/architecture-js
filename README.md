# architecture-js [![Build Status](https://secure.travis-ci.org/daytonn/architecture-js.png)](http://travis-ci.org/daytonn/architecture-js)

##About
ArchitectureJS is a suite of tools to help you build and manage complex javascript applications and frameworks. With ArchitectureJS you can compile, and compress your javascript application all in real time as you write plain old vanilla javascript, create project scaffolding and generate dynamic templates, manage third-party and custom libraries. In addition to large applications, ArchitectureJS is perfect for developing your own javascript frameworks and libraries. ArchitectureJS contains the following tools to help you build modern javascript applications and frameworks:

* Project-specific configuration to manage defaults and dependencies
* JavaScript Compiler (Sprockets 1.0.2)
* JavaScript Compression (JSMin)
* Scaffold generation using editable templates
* Custom local JavaScript package management
* Realtime file monitoring utility to compile your application while you code

## Installation
Requires ruby version 1.9 or higher. The best way is using rubygems:

    gem install architecture-js

Or include it in your projects `Gemfile` with Bundler:

    gem 'architecture-js', '~> 0.2.0'

## Getting Started
ArchitectureJS comes with a small command line utility named `architect` to manage your architecture projects. To be sure architecture-js is installed correctly, type this command:

    architect -h
 
If `architect` is installed correctly, this command will display the help menu. You will see there are only a few simple commands: create, compile, watch, and generate _(not implemented)_. These commands are all you need to manage complex javascript applications and frameworks.

To create an architect application use the create command (where "myapp" is the name of _your_ application)

    architect create myapp

This will create the default project scaffold:

    /lib
    /src/
        myapp.js
    myapp.blueprint

<a id="configuration"></a>
## Default Configurtaion
The `myapp.blueprint` file contains the configuration for your architecture project. These few simple settings will give you a great amount of control over the compilation of your project. The default config file looks something like this

    blueprint: default
    src_dir: src
    build_dir: lib
    asset_root: ../
    output: compressed
    name: myapp

### blueprint
The `blueprint` is what determines the application scaffold and configuration settings. It defaults to `default` which is a bare bones project layout for simple javascript libraries. It has one directory for source files (src), and a build directory named "lib" for distributable code. Other blueprints can be plugged in to support any architecture. These blueprints can extend the basic architecture project including the scaffolding, templates, compilation tasks, and default templates. All blueprints will share the default configuration options (although some blueprints may treat them differently).

### src_dir
The `src_dir` is the directory or directories where the source files that will be compiled into the build directory (`build_dir`) are kept. By default the `src_dir` is usually a single directory represented as a string:

    src_dir: src

 but can be multiple directories. If you wished to compile the files in the three directories named "classes", "widgets", and "plugins", src_dir would be an array:

    src_dir: [classes, widgets, plugins]


Any files in these three directories would be compiled into the build directory, including their requirements.

### build_dir
The `build_dir` is where all your source files will be compiled, including their requirements.

### asset_root
The `asset_root` is where stylesheet and image assets will be installed by the `provide` directive. By default the `asset_root` is the project root. Stylesheets and images will be placed in css and images directories respectively.

<a id="output"></a>
### output
The `output` determines whether the compiled javascript will be `compressed` or `expanded`, which are the two possible values. The JSMin engine is used for compression.

### name
The `name` is the name of your architecture project. The name value can be used by the blueprint in a variety of ways. By default the name is used to create the main application file in the /src directory.

<a id="sprockets"></a>
## Sprockets
ArchitectureJS uses the Sprockets javascript compiler under the hood to allow you to create a file system architecture that corresponds to your application architecture. This is the heart of the ArchitectureJS system. In addition to concatenating scripts together with special comments, Sprockets can also include stylesheet and image assets required by script files. It has a basic syntax using javascript comments, gracefully enhancing plain old vanilla javascript.

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

## Scaffolds

The ArchitectureJS scaffolding allows you to generate custom script templates dynamically. This system is a great way to share common boilerplate code in one easy to maintain place. 

### generate
The `generate` command will create a new file based on a predefined template. Default template files are defined by the blueprint the project is using. The `default` blueprint only has one template named `blank`:

    architect generate blank test

This will create a blank javascript file named `test.js` in the current directory. This doesn't really do much, the only reason it's there is to test the template generator. However, You can add your own templates by putting files inside a `/templates` directory inside your project root. For example, if you created a `/templates/class.js` file, you could generate a class template with the following command:

    architect generate class widget

This would create a file named `widget.js` in the current directory based on the contents of `/templates/class.js`. At this point the file is just an empty file. Let's make a more practical template. We'll edit the `class.js` template to take advantage of the command line options:

```ruby
    <%= options[:name] %> = (function() {
    <% if options[:f] %>
        function <%= options[:name] %>() {};
        return new <%= options[:name] %>();
    <% else %>
        var <%= options[:name] %> = function() {};
        return <%= options[:name] %>;
    <% end %>
    })();
```

The syntax may be a little strange if you've never worked with ERB but this template gives us a great way to generate template files via the command line with `architect`. There are two types of variable you can pass to a template via the generate command: named variables and flags. Named variables allow you to set variables with values. To pass a named variable you use the double dash syntax `architect generate class widget --name "Widget"`, passing the value as the next argument. Flags are simple boolean switches that turn on a flag. To pass a flag, use the single dash syntax `architect generate class widget -f`. All arguments passed will be available through the options variable in the template. Using the `class` template from above we can generate two basic class models using the command options:

    architect generate class widget --name "Foo"

Which would create:

```js
    Foo = (function() {
        var Foo = function() {};
        return Foo;
    })();
```

We can generate a slightly different class template using the -f flag:

    architect generate class widget --name "Foo" -f

Which generates:

```js
    Foo = (function() {
        function Foo() {};
        return new Foo();
    })();
```

This is a slightly contrived but not wholly unrealistic example of how you can use the architect template generator. Some blueprints contain default templates which work without the presence of a `/templates` folder. 

## Package Management
_Not Yet Implemented_

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

