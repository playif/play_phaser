part of P2;

class ContactMaterial extends p2.ContactMaterial {
  ContactMaterial(Material materialA, Material materialB, {num friction: 0.3, num restitution: 0, num stiffness: p2.Equation.DEFAULT_STIFFNESS, num relaxation: p2.Equation.DEFAULT_RELAXATION, num frictionStiffness: p2.Equation.DEFAULT_STIFFNESS, num frictionRelaxation: p2.Equation.DEFAULT_RELAXATION, num surfaceVelocity: 0}) : super(materialA, materialB, friction: friction, restitution: restitution, stiffness: stiffness, relaxation: relaxation, frictionStiffness: frictionStiffness, frictionRelaxation: frictionRelaxation, surfaceVelocity: surfaceVelocity) {
  }
}
