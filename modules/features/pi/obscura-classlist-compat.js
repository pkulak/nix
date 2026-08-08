(() => {
  const descriptor = Object.getOwnPropertyDescriptor(Element.prototype, "classList");
  if (descriptor && !descriptor.set && descriptor.configurable) {
    Object.defineProperty(Element.prototype, "classList", {
      ...descriptor,
      set(value) {
        this.setAttribute("class", String(value));
      },
    });
  }
})();
