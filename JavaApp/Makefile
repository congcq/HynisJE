# Prerequisite variables
SOURCEDIR := src
OUTPUTDIR := build

SOURCES := $(shell find $(SOURCEDIR) -type f -name '*.java')
CLASSES := $(SOURCES:$(SOURCEDIR)/%.java=$(OUTPUTDIR)/%.class)

TARGETS := $(shell find $(SOURCEDIR) -mindepth 1 -maxdepth 1 -type d)
TARGETS := $(TARGETS:$(SOURCEDIR)/%=$(OUTPUTDIR)/%.jar)

# Add all jars to classpath and allow compiling with private API
JCFLAGS := -cp "$(subst $() $(),:,$(wildcard $(SOURCEDIR)/*/):$(wildcard libs/*/*.jar))" -XDignore.symbol.file

all: $(TARGETS)

# Rules for building java class
$(CLASSES): $(OUTPUTDIR)/%.class: $(SOURCEDIR)/%.java
	@set -e
	$(eval TARGET=$(word 2, $(subst /, ,$@)))
	@mkdir -p $(OUTPUTDIR)/classes
	@mkdir -p $(dir $@)
	@echo "Compiling $<"
	@$(BOOTJDK)/javac $(JCFLAGS) -d $(OUTPUTDIR)/classes $<
	@cp $(@:$(OUTPUTDIR)/$(TARGET)/%.class=$(OUTPUTDIR)/classes/%*.class) $(dir $@)/

$(OUTPUTDIR)/launcher.jar: $(CLASSES)
	@set -e
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cf $@ -C $(basename $@) .

$(OUTPUTDIR)/lwjgl-3.4.1.jar: $(CLASSES)
	@set -e
	@echo "Creating $@"
	@mkdir -p $(OUTPUTDIR)/lwjgl-3.4.1_lib
	@cd $(OUTPUTDIR)/lwjgl-3.4.1_lib && find ../../libs/lwjgl-3.4.1 -name 'lwjgl*.jar' -exec $(BOOTJDK)/jar -xf {} \; && rm -rf META-INF
	@cp -R $(OUTPUTDIR)/lwjgl-3.4.1/* $(OUTPUTDIR)/lwjgl-3.4.1_lib/
	@$(BOOTJDK)/jar -cf $@ -C $(OUTPUTDIR)/lwjgl-3.4.1_lib .

$(OUTPUTDIR)/patchjna_agent.jar: $(CLASSES)
	@set -e
	@mv $(basename $@)/com/sun/jna/Platform.class $(basename $@)/com/sun/jna/Platform.class.patch
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cfm $@ $(SOURCEDIR)/patchjna_agent.txt -C $(basename $@) .

$(OUTPUTDIR)/patchsvc.jar: $(CLASSES)
	@set -e
	@mv $(basename $@)/de/maxhenkel/lame4j/Mp3Decoder.class $(basename $@)/de/maxhenkel/lame4j/Mp3Decoder.class.patch
	@mv $(basename $@)/de/maxhenkel/lame4j/Mp3Encoder.class $(basename $@)/de/maxhenkel/lame4j/Mp3Encoder.class.patch
	@mv $(basename $@)/de/maxhenkel/opus4j/OpusDecoder.class $(basename $@)/de/maxhenkel/opus4j/OpusDecoder.class.patch
	@mv $(basename $@)/de/maxhenkel/opus4j/OpusEncoder.class $(basename $@)/de/maxhenkel/opus4j/OpusEncoder.class.patch
	@mv $(basename $@)/de/maxhenkel/rnnoise4j/Denoiser.class $(basename $@)/de/maxhenkel/rnnoise4j/Denoiser.class.patch
	@mv $(basename $@)/de/maxhenkel/speex4j/AutomaticGainControl.class $(basename $@)/de/maxhenkel/speex4j/AutomaticGainControl.class.patch
	@rm -rf $(basename $@)/de/maxhenkel/*/*.class
	@echo "Creating $@"
	@$(BOOTJDK)/jar -cfm $@ $(SOURCEDIR)/patchsvc.txt -C $(basename $@) .

clean:
	rm -rf $(OUTPUTDIR)

.SUFFIXES: .java
.PHONY: all clean
