require 'test_helper'
require 'hanami/utils/class'

describe Hanami::Utils::Class do
  before do
    class Bar
      def level
        'top'
      end
    end

    class Foo
      class Bar
        def level
          'nested'
        end
      end
    end

    module App
      module Layer
        class Step
        end
      end

      module Service
        class Point
        end
      end

      class ServicePoint
      end
    end
  end

  describe '.load!' do
    it 'loads the class from the given static string' do
      Hanami::Utils::Class.load!('App::Layer::Step').must_equal(App::Layer::Step)
    end

    it 'loads the class from the given static string and namespace' do
      Hanami::Utils::Class.load!('Step', App::Layer).must_equal(App::Layer::Step)
    end

    it 'loads the class from the given class name' do
      Hanami::Utils::Class.load!(App::Layer::Step).must_equal(App::Layer::Step)
    end

    it 'raises an error in case of missing class' do
      -> { Hanami::Utils::Class.load!('Missing') }.must_raise(NameError)
    end
  end

  describe '.load' do
    it 'loads the class from the given static string' do
      Hanami::Utils::Class.load('App::Layer::Step').must_equal(App::Layer::Step)
    end

    it 'loads the class from the given static string and namespace' do
      Hanami::Utils::Class.load('Step', App::Layer).must_equal(App::Layer::Step)
    end

    it 'loads the class from the given class name' do
      Hanami::Utils::Class.load(App::Layer::Step).must_equal(App::Layer::Step)
    end

    it 'returns nil in case of missing class' do
      Hanami::Utils::Class.load('Missing').must_equal(nil)
    end
  end

  describe '.load_from_pattern!' do
    it 'loads the class within the given namespace' do
      klass = Hanami::Utils::Class.load_from_pattern!('(Hanami|Foo)::Bar')
      klass.new.level.must_equal 'nested'
    end

    it 'loads the class within the given namespace, when first namespace does not exist' do
      klass = Hanami::Utils::Class.load_from_pattern!('(NotExisting|Foo)::Bar')
      klass.new.level.must_equal 'nested'
    end

    it 'loads the class within the given namespace when first namespace in pattern is correct one' do
      klass = Hanami::Utils::Class.load_from_pattern!('(Foo|Hanami)::Bar')
      klass.new.level.must_equal 'nested'
    end

    it 'loads the class from the given static string' do
      Hanami::Utils::Class.load_from_pattern!('App::Layer::Step').must_equal(App::Layer::Step)
    end

    it 'raises error for missing constant' do
      error = -> { Hanami::Utils::Class.load_from_pattern!('MissingConstant') }.must_raise(NameError)
      error.message.must_equal 'uninitialized constant MissingConstant'
    end

    it 'raises error for missing constant with multiple alternatives' do
      error = -> { Hanami::Utils::Class.load_from_pattern!('Missing(Constant|Class)') }.must_raise(NameError)
      error.message.must_equal 'uninitialized constant Missing(Constant|Class)'
    end

    it 'raises error with full constant name' do
      error = -> { Hanami::Utils::Class.load_from_pattern!('Step', App) }.must_raise(NameError)
      error.message.must_equal 'uninitialized constant App::Step'
    end

    it 'raises error with full constant name and multiple alternatives' do
      error = -> { Hanami::Utils::Class.load_from_pattern!('(Step|Point)', App) }.must_raise(NameError)
      error.message.must_equal 'uninitialized constant App::(Step|Point)'
    end

    it 'loads the class from given string, by interpolating tokens' do
      Hanami::Utils::Class.load_from_pattern!('App::Service(::Point|Point)').must_equal(App::Service::Point)
    end

    it 'loads the class from given string, by interpolating string tokens and respecting their order' do
      Hanami::Utils::Class.load_from_pattern!('App::Service(Point|::Point)').must_equal(App::ServicePoint)
    end

    it 'loads the class from given string, by interpolating tokens and not stopping after first fail' do
      Hanami::Utils::Class.load_from_pattern!('App::(Layer|Layer::)Step').must_equal(App::Layer::Step)
    end

    it 'loads class from given string and namespace' do
      Hanami::Utils::Class.load_from_pattern!('(Layer|Layer::)Step', App).must_equal(App::Layer::Step)
    end
  end
end
