# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

[ { is_symmetric: true,  label: 'is in conflict with',     asymmetric_label: 'is in conflict with',    code: 'is.in.conflict.with',    is_hierarchical:  false},
  { is_symmetric: true,  label: 'is affiliated with',      asymmetric_label: 'is affiliated with',     code: 'is.affiliated.with',     is_hierarchical: false},
  { is_symmetric: false, label: 'is mother of',            asymmetric_label: 'is child of',            code: 'is.child.of',            is_hierarchical: false, asymmetric_code: 'is.mother.of'},
  { is_symmetric: false, label: 'has as an instantiation', asymmetric_label: 'is an instantiation of', code: 'is.an.instantiation.of', is_hierarchical: false, asymmetric_code: 'has.as.an.instantiation'},
  { is_symmetric: false, label: 'has as a part',           asymmetric_label: 'is part of',             code: 'is.part.of',             is_hierarchical: true,  asymmetric_code: 'has.as.a.part'}
].each{|a| FeatureRelationType.update_or_create(a)}

[ { name: 'Popular Standard (romanization)',         code: 'roman.popular' },
  { name: 'Scholarly Standard (romanization)',       code: 'roman.scholar' },
  { name: 'Chinese Characters (simplified)',         code: 'simp.chi' },
  { name: 'Tibetan Script (secondary romanization)', code: 'pri.tib.sec.roman' },
  { name: 'Tibetan Script (secondary Chinese)',      code: 'pri.tib.sec.chi' },
  { name: 'Devanagari Script',                       code: 'deva' }
].each{|a| View.update_or_create(a)}