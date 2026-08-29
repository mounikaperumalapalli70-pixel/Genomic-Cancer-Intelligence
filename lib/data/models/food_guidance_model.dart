class FoodGuidanceModel {
  final String cancerType;
  final String overview;
  final List<String> foodsToInclude;
  final List<String> foodsToLimit;
  final String hydrationAdvice;
  final List<String> mealGuidance;
  final String disclaimer;

  const FoodGuidanceModel({
    required this.cancerType,
    required this.overview,
    required this.foodsToInclude,
    required this.foodsToLimit,
    required this.hydrationAdvice,
    required this.mealGuidance,
    this.disclaimer =
        'Nutritional guidance is supportive and evidence-based for general metabolic wellness. Food does not cure cancer and must not replace professional medical treatment or oncology care.',
  });

  static FoodGuidanceModel getGuidanceForCancerType(String cancerType) {
    if (cancerType.toLowerCase().contains('lung')) {
      return const FoodGuidanceModel(
        cancerType: 'Lung Cancer Support',
        overview:
            'Focus on anti-inflammatory, antioxidant-rich foods to support pulmonary tissue resilience and maintain healthy body mass.',
        foodsToInclude: [
          'Cruciferous vegetables (Broccoli, cauliflower, kale)',
          'Antioxidant-dense berries (Blueberries, blackberries, pomegranates)',
          'Omega-3 rich foods (Walnuts, flaxseeds, chia seeds)',
          'Lean protein sources (Lentils, tofu, eggs, wild salmon)',
          'Carotenoid-rich vegetables (Carrots, sweet potatoes, spinach)',
        ],
        foodsToLimit: [
          'Ultra-processed meats and charbroiled foods',
          'Refined sugars and high-fructose corn syrup',
          'Excessive saturated fats and trans-fat snacks',
          'High-sodium packaged goods and canned soups',
        ],
        hydrationAdvice:
            'Maintain 2.5 - 3.0 Litres of fluids daily (warm water, ginger herbal tea, clear broths) to support mucus clearance and cellular hydration.',
        mealGuidance: [
          'Eat 4-5 smaller, nutrient-dense meals throughout the day rather than 3 large meals.',
          'Incorporate plant-based protein into every meal to preserve lean muscle tissue.',
          'Consume steamed or lightly cooked vegetables for gentle digestion.',
        ],
      );
    } else if (cancerType.toLowerCase().contains('breast')) {
      return const FoodGuidanceModel(
        cancerType: 'Breast Cancer Support',
        overview:
            'Emphasis on high-fiber whole grains, phytoestrogen-balanced legumes, and cruciferous nutrients supporting hormonal equilibrium.',
        foodsToInclude: [
          'Dark leafy greens (Spinach, arugula, Swiss chard)',
          'Whole grains (Quinoa, oats, brown rice, barley)',
          'Legumes & pulses (Chickpeas, black beans, lentils)',
          'Healthy monounsaturated fats (Avocados, extra virgin olive oil)',
          'Green tea and turmeric with black pepper (curcumin absorption)',
        ],
        foodsToLimit: [
          'Alcohol and sweetened carbonated beverages',
          'Processed delicatessen meats and deep-fried foods',
          'High-glycemic refined flour products',
          'Excessive dairy with high saturated fats',
        ],
        hydrationAdvice:
            'Drink 2.5 Litres of water daily, infused with lemon or mint, to promote natural metabolic detoxification.',
        mealGuidance: [
          'Aim for at least 30g of dietary fiber daily through diverse whole plants.',
          'Opt for healthy cold-pressed oils rather than refined cooking oils.',
          'Keep meals colorful with at least 3 distinct vegetable colors per plate.',
        ],
      );
    } else {
      return const FoodGuidanceModel(
        cancerType: 'General Genomic Wellness',
        overview:
            'Evidence-based supportive nutrition prioritizing cellular cellular repair, immune vitality, and anti-inflammatory defense.',
        foodsToInclude: [
          'Colorful seasonal fruits and cruciferous vegetables',
          'Fiber-rich legumes, seeds, and whole ancient grains',
          'Plant polyphenols (Green tea, turmeric, berries)',
          'Adequate clean protein for tissue repair',
        ],
        foodsToLimit: [
          'Processed meats and high-temperature fried foods',
          'Excessive refined sugars and artificial preservatives',
          'Heavy alcohol intake and sugary drinks',
        ],
        hydrationAdvice:
            'Aim for 2.5 Litres of clean water daily, keeping hydration steady across the morning and afternoon.',
        mealGuidance: [
          'Prioritize fresh, whole, minimally processed ingredients.',
          'Incorporate balanced macronutrients (protein, healthy fats, complex carbs) into every meal.',
        ],
      );
    }
  }
}
