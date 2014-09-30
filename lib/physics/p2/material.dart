part of P2;

class Material extends p2.Material {
  String name;
  Material(String name) {
    /**
     * @property {string} name - The user defined name given to this Material.
     * @default
     */
    this.name = name;
  }
}
