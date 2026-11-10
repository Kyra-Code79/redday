import 'package:flutter/material.dart';
import '../models/food_suggestion.dart';

class NutritionRepository {
  static const List<FoodSuggestion> allSuggestions = [
    // 1. Dark Chocolate
    FoodSuggestion(
      id: 'dark_chocolate',
      name: 'Dark Chocolate (70%+ Cocoa)',
      icon: Icons.cookie_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'High Magnesium & Flavonoids',
      benefit: 'Relaxes contracted uterine muscles and stimulates endorphin & dopamine release.',
      whyItHelpsOnRedDays:
          'Prostaglandin surges during your period cause acute muscular cramping. Magnesium is a natural muscle relaxant that reduces uterine spasms, while dark cacao satisfies intense luteal/menstrual cravings without causing blood sugar spikes.',
      clinicalSource: 'PubMed / European Journal of Obstetrics & Gynaecology',
      clinicalEvidence:
          'Clinical reviews demonstrate that magnesium acts as a physiological calcium antagonist in the myometrium, inhibiting uterine smooth muscle contractions and vascular spasms. Flavanols in dark chocolate also down-regulate inflammatory biomarkers and elevate central dopamine and serotonin.',
      scientificReference:
          'Parazzini F, et al. Magnesium in gynecological practice: A review. Eur J Obstet Gynecol Reprod Biol. 2017; Fathizadeh N, et al. Iran J Nurs Midwifery Res. 2010.',
      allergenTags: ['dairy'],
      cravingTags: ['chocolate', 'sweets', 'comfort'],
      dishes: [
        FoodDish(
          name: 'Warm Dark Chocolate & Walnut Mug Cake',
          type: 'Warm Comfort Treat',
          description:
              'A rich, fluffy 2-minute single-serve microwave cake made with 100% dark cocoa powder, almond or oat flour, a dash of cinnamon, and dark chocolate chips that melt into a warm molten center.',
          quickTip: 'Mix 2 tbsp oat flour, 1 tbsp cocoa, 1 tbsp maple syrup, 2 tbsp milk, and microwave for 60 seconds.',
          safeSubstitute: 'Use oat milk and certified gluten-free oat flour for a dairy-free & gluten-free treat.',
        ),
        FoodDish(
          name: 'Chewy Dark Choco-Chip Oatmeal Cookies',
          type: 'Sweet Snack',
          description:
              'Warm golden cookies combining the slow-burning complex carbs of whole rolled oats with rich 72% dark chocolate chunks to sustain steady energy and calm PMS mood dips.',
          quickTip: 'Bake with coconut oil or grass-fed butter for rich tenderness.',
          safeSubstitute: 'Oat-based cookies are naturally nut-free.',
        ),
        FoodDish(
          name: 'Velvety Hot Cocoa with Cinnamon & Oat Milk',
          type: 'Soothing Drink',
          description:
              'Unsweetened Dutch dark cocoa whisked into warm creamy oat milk with a touch of pure vanilla and honey. The warmth soothes abdominal tension while the magnesium absorbs rapidly.',
          quickTip: 'Add a tiny pinch of sea salt and cinnamon to heighten the chocolate notes.',
          safeSubstitute: 'Naturally 100% dairy-free with oat, almond, or soy milk.',
        ),
        FoodDish(
          name: 'Dark Chocolate Dipped Fresh Strawberries',
          type: 'Fresh Treat',
          description:
              'Sweet juicy strawberries paired with melted dark chocolate. Vitamin C from berries enhances mineral absorption while satisfying sweet cravings.',
          quickTip: 'Melt chocolate chips with 1/2 tsp coconut oil for a glossy smooth dip.',
        ),
      ],
    ),

    // 2. Fresh Ginger
    FoodSuggestion(
      id: 'fresh_ginger',
      name: 'Fresh Ginger Root',
      icon: Icons.local_fire_department_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'Gingerols & Shogaols (Natural Anti-inflammatory)',
      benefit: 'Acts similarly to over-the-counter NSAIDs by suppressing pain-inducing prostaglandin synthesis.',
      whyItHelpsOnRedDays:
          'Clinical trials show that 250mg to 500mg of ginger powder taken during the first three days of menstruation reduces pain severity as effectively as ibuprofen, while also relieving nausea, fatigue, and digestive distress.',
      clinicalSource: 'PubMed / Journal of Alternative & Complementary Medicine',
      clinicalEvidence:
          'A landmark randomized, double-blind clinical trial showed that 250 mg ginger rhizome powder taken four times daily had equal analgesic efficacy to 400 mg ibuprofen and 250 mg mefenamic acid for primary dysmenorrhea pain reduction, with significantly lower gastrointestinal irritation.',
      scientificReference:
          'Ozgoli G, Goli M, Moattar F. Comparison of Effects of Ginger, Mefenamic Acid, and Ibuprofen on Pain in Patients with Primary Dysmenorrhea. J Altern Complement Med. 2009; Daily JW, et al. Pain Med. 2015.',
      allergenTags: [],
      cravingTags: ['tea', 'warm_soups', 'comfort'],
      dishes: [
        FoodDish(
          name: 'Fresh Honey-Lemon Ginger Tea',
          type: 'Soothing Drink',
          description:
              'Thinly sliced fresh ginger root simmered in boiling water for 10 minutes, poured hot over organic wildflower honey and fresh lemon juice.',
          quickTip: 'Crush or grate ginger with the skin on for maximum gingerol extraction.',
        ),
        FoodDish(
          name: 'Cozy Ginger Carrot Coconut Soup',
          type: 'Warm Meal',
          description:
              'Velvety smooth pureed roasted carrots, fresh grated ginger root, garlic, and coconut cream. Warm, nourishing, and gentle on sensitive period stomachs.',
          quickTip: 'Pair with warm sourdough or rice for a deeply satisfying lunch.',
          safeSubstitute: 'Naturally dairy-free, nut-free, and vegan.',
        ),
        FoodDish(
          name: 'Ginger Sesame Sautéed Rice Bowl',
          type: 'Warm Meal',
          description:
              'Steamed brown or jasmine rice tossed with finely minced ginger, sesame oil, tamari, and steamed greens for a warm stomach-settling meal.',
          quickTip: 'Top with an egg or edamame for grounding protein.',
        ),
      ],
    ),

    // 3. Spinach & Dark Leafy Greens
    FoodSuggestion(
      id: 'spinach_greens',
      name: 'Spinach & Dark Leafy Greens',
      icon: Icons.eco_outlined,
      category: FoodCategory.ironEnergy,
      keyNutrient: 'Non-Heme Iron, Folate, Vitamin K & Magnesium',
      benefit: 'Replenishes systemic iron stores depleted by menstrual flow to combat exhaustion and dizziness.',
      whyItHelpsOnRedDays:
          'Heavy or moderate menstrual bleeding drains iron, the core component of red blood cell hemoglobin. Dark leafy greens help replenish cellular oxygenation and provide magnesium to ease pelvic muscle aches.',
      clinicalSource: 'WHO (World Health Organization) & NIH Guidelines',
      clinicalEvidence:
          'WHO global guidelines on reproductive health emphasize dietary iron intake for all menstruating women to offset menstrual hemoglobin losses (averaging 30-40 mL per cycle) and prevent subclinical iron depletion, cognitive fatigue, and impaired tissue oxygenation.',
      scientificReference:
          'WHO Guideline: Daily iron and folic acid supplementation in menstruating adult women and adolescent girls. World Health Organization (WHO), Geneva; NIH Office of Dietary Supplements: Iron Fact Sheet.',
      allergenTags: [],
      cravingTags: ['crisp_greens', 'comfort', 'pasta_rice'],
      dishes: [
        FoodDish(
          name: 'Spinach, Tomato & Feta Omelette',
          type: 'Warm Breakfast',
          description:
              'Fluffy pasture-raised eggs folded with wilted baby spinach, cherry tomatoes, and crumbled feta cheese. Packed with bioavailable protein, iron, and choline.',
          quickTip: 'Cooking spinach unlocks significantly higher bioavailable iron than raw leaves.',
          safeSubstitute: 'Substitute feta with avocado or nutritional yeast if avoiding dairy.',
        ),
        FoodDish(
          name: 'Creamy Garlic Spinach Penne Pasta',
          type: 'Comfort Meal',
          description:
              'Al dente penne pasta coated in a silky garlic-spinach cream sauce (or olive oil garlic emulsion) with cracked black pepper and parmesan.',
          quickTip: 'Add lemon zest to boost vitamin C for superior iron uptake.',
          safeSubstitute: 'Use gluten-free chickpea pasta for extra iron and zero gluten.',
        ),
        FoodDish(
          name: 'Tropical Green Berry Energy Smoothie',
          type: 'Fresh Drink',
          description:
              'Two packed handfuls of baby spinach blended with frozen mango, banana, and orange juice. The high vitamin C content multiplies plant iron absorption by 300%.',
          quickTip: 'Spinach leaves blend completely tasteless when paired with sweet fruit.',
        ),
        FoodDish(
          name: 'Warm Sesame Garlic Wilted Spinach',
          type: 'Quick Side',
          description:
              'Fresh spinach leaves flash-sautéed in toasted sesame oil, minced garlic, and toasted sesame seeds in under 3 minutes.',
          quickTip: 'Great warm side dish alongside rice or protein.',
        ),
      ],
    ),

    // 4. Wild Salmon & Chia Seeds
    FoodSuggestion(
      id: 'salmon_chia',
      name: 'Wild Salmon & Chia Seeds',
      icon: Icons.set_meal_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'EPA & DHA Omega-3 Fatty Acids & Protein',
      benefit: 'Dramatically dampens inflammatory prostaglandins that cause intense uterine and lower back cramps.',
      whyItHelpsOnRedDays:
          'Omega-3 fatty acids compete with arachidonic acid in cell membranes, directly lowering the synthesis of inflammatory prostaglandins (PGF2-alpha) responsible for intense uterine cramps and pelvic throbbing.',
      clinicalSource: 'PubMed / International Journal of Gynecology & Obstetrics',
      clinicalEvidence:
          'Randomized clinical trials show that daily omega-3 fatty acid intake significantly reduces the intensity and duration of primary dysmenorrhea symptoms by suppressing inflammatory cyclooxygenase pathways and prostaglandin F2-alpha (PGF2α) synthesis.',
      scientificReference:
          'Rahbar N, et al. Effect of omega-3 fatty acids on intensity of primary dysmenorrhea. Int J Gynaecol Obstet. 2012; Mohammadi MM, et al. Complement Ther Med. 2022.',
      allergenTags: ['seafood'],
      cravingTags: ['healthy_fats', 'comfort', 'pasta_rice'],
      dishes: [
        FoodDish(
          name: 'Pan-Seared Teriyaki Salmon & Steamed Rice',
          type: 'Warm Meal',
          description:
              'Crispy-skinned wild salmon fillet glazed in a sweet teriyaki reduction, served alongside warm jasmine rice and steamed broccoli.',
          quickTip: 'Wild-caught salmon provides twice the omega-3 density of farmed fish.',
        ),
        FoodDish(
          name: 'Smoked Salmon & Avocado Toast',
          type: 'Comfort Snack',
          description:
              'Toasted artisanal sourdough smeared with mashed lemon-avocado, topped with cold-smoked salmon slices, capers, and a pinch of everything seasoning.',
          quickTip: 'Combines anti-inflammatory omega-3 with potassium-rich healthy avocado fats.',
          safeSubstitute: 'Use gluten-free bread if gluten-sensitive.',
        ),
        FoodDish(
          name: 'Vanilla Berry Chia Seed Pudding (Plant Omega Alternative)',
          type: 'Sweet Snack',
          description:
              'Chia seeds hydrated overnight in creamy oat milk with vanilla extract and pure maple syrup, topped with fresh raspberries. High plant ALA omega-3.',
          quickTip: 'Completely fish-free omega-3 alternative for vegetarian or seafood-allergic users.',
          safeSubstitute: '100% seafood-free, dairy-free, and vegan.',
        ),
      ],
    ),

    // 5. Bananas
    FoodSuggestion(
      id: 'bananas',
      name: 'Bananas',
      icon: Icons.lunch_dining_outlined,
      category: FoodCategory.antiBloat,
      keyNutrient: 'Potassium, Vitamin B6 & Soluble Fiber',
      benefit: 'Acts as a natural diuretic to relieve water retention and PMS bloating while boosting serotonin.',
      whyItHelpsOnRedDays:
          'Progesterone drops prior to flow trigger sodium and water retention in abdominal tissues. High potassium restores intracellular sodium balance, rapidly reducing the sensation of bloating. Vitamin B6 also aids serotonin production to stabilize mood.',
      clinicalSource: 'Mayo Clinic & British Medical Journal (BMJ)',
      clinicalEvidence:
          'Mayo Clinic clinical guidance notes high dietary potassium counteracts sodium-mediated cyclic fluid retention. BMJ systematic reviews confirm Vitamin B6 serves as an essential cofactor in dopamine and serotonin synthesis, improving PMS depressive symptoms and fluid retention.',
      scientificReference:
          'Wyatt KM, et al. Efficacy of vitamin B-6 in the treatment of premenstrual syndrome: systematic review. BMJ. 1999; Mayo Clinic Women\'s Health: Edema and water retention during menstruation.',
      allergenTags: [],
      cravingTags: ['sweets', 'berries', 'oats', 'comfort'],
      dishes: [
        FoodDish(
          name: 'Warm Cinnamon Walnut Banana Bread',
          type: 'Warm Comfort Treat',
          description:
              'Tender, fragrant homemade banana bread made with ripe bananas, cinnamon, a touch of maple syrup, and optional toasted walnuts.',
          quickTip: 'The riper the bananas (brown spots), the sweeter and easier to digest.',
          safeSubstitute: 'Omit walnuts for a 100% nut-free recipe.',
        ),
        FoodDish(
          name: 'Frozen Dark Choco Peanut Butter Banana Bites',
          type: 'Sweet Snack',
          description:
              'Banana slices layered with creamy peanut (or sunflower) butter, dipped in melted dark chocolate and frozen into crisp bite-sized treats.',
          quickTip: 'Keep a batch in the freezer for when instant cravings strike.',
          safeSubstitute: 'Use sunflower seed butter if allergic to peanuts or tree nuts.',
        ),
        FoodDish(
          name: 'Fluffy 3-Ingredient Banana Oat Pancakes',
          type: 'Warm Breakfast',
          description:
              'Whisk 1 ripe banana, 1/2 cup rolled oats, and 1 egg (or plant milk) into a batter and griddle in coconut oil until golden brown.',
          quickTip: 'No added refined sugars needed — bananas naturally sweeten the batter.',
        ),
      ],
    ),

    // 6. Whole Rolled Oats
    FoodSuggestion(
      id: 'rolled_oats',
      name: 'Whole Rolled Oats',
      icon: Icons.breakfast_dining_outlined,
      category: FoodCategory.moodComfort,
      keyNutrient: 'Complex Carbohydrates, Beta-Glucan & Zinc',
      benefit: 'Maintains steady blood glucose to prevent mood crashes and provides zinc to ease cramp duration.',
      whyItHelpsOnRedDays:
          'Complex carbohydrates promote continuous, gentle uptake of tryptophan into the brain, sustaining serotonin synthesis. The soluble beta-glucan fiber supports digestive regularity, which can be sluggish during menstruation.',
      clinicalSource: 'ACOG (American College of Obstetricians & Gynecologists)',
      clinicalEvidence:
          'ACOG clinical guidelines for premenstrual syndrome management recommend complex, slow-digesting carbohydrates to prevent rapid glycemic swings, maintain sustained brain serotonin concentrations, and reduce food cravings and irritability.',
      scientificReference:
          'ACOG Practice Bulletin No. 15: Management of Premenstrual Disorders. American College of Obstetricians and Gynecologists (ACOG).',
      allergenTags: ['gluten'],
      cravingTags: ['oats', 'comfort', 'sweets', 'warm_soups'],
      dishes: [
        FoodDish(
          name: 'Warm Baked Apple Cinnamon Oatmeal',
          type: 'Warm Comfort Meal',
          description:
              'Rolled oats baked with diced crisp apples, ground cinnamon, pure maple syrup, and milk until golden and aromatic. Like warm apple pie for breakfast.',
          quickTip: 'Make a pan on Sunday and reheat individual portions during your period days.',
          safeSubstitute: 'Use certified gluten-free rolled oats and plant milk for dairy/gluten allergies.',
        ),
        FoodDish(
          name: 'No-Bake Honey Oat & Dark Choco Energy Bites',
          type: 'Quick Snack',
          description:
              'Rolled oats, almond butter, honey, and dark chocolate chips rolled into chewy chilled bites that provide instant, non-jittery energy.',
          quickTip: 'Store in an airtight jar in the fridge for up to two weeks.',
          safeSubstitute: 'Use sunflower seed butter if nut-allergic.',
        ),
        FoodDish(
          name: 'Overnight Raspberry Vanilla Oats',
          type: 'Fresh Breakfast',
          description:
              'Oats steeped overnight in milk, chia seeds, and pure vanilla, layered with crushed fresh raspberries for antioxidant and fiber support.',
          quickTip: 'Eat chilled or pop in the microwave for 45 seconds for a warm porridge.',
        ),
      ],
    ),

    // 7. Chamomile & Peppermint Herbal Teas
    FoodSuggestion(
      id: 'chamomile_peppermint',
      name: 'Chamomile & Peppermint Tea',
      icon: Icons.emoji_food_beverage_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'Apigenin, Glycine & Menthol Antispasmodics',
      benefit: 'Increases urinary levels of glycine, relaxing nerve and smooth uterine muscle spasms.',
      whyItHelpsOnRedDays:
          'Chamomile contains apigenin which binds to GABA receptors in the central nervous system to induce tranquility and relieve period anxiety, while peppermint menthol relaxes gastrointestinal and uterine smooth muscle to ease painful cramping.',
      clinicalSource: 'PubMed / Cochrane Database & Iranian Journal of Obstetrics',
      clinicalEvidence:
          'A randomized clinical trial reported that consuming chamomile tea three times daily significantly attenuated the intensity of primary dysmenorrhea pain and psychological distress by elevating systemic glycine, which acts as a central antispasmodic.',
      scientificReference:
          'Jenabi E, Samavat S. The effect of chamomile tea on primary dysmenorrhea and menstrual bleeding. Iran J Obstet Gynecol Infertil. 2010; Mehmood MH, et al. J Ethnopharmacol. 2015.',
      allergenTags: [],
      cravingTags: ['tea', 'warm_soups', 'comfort'],
      dishes: [
        FoodDish(
          name: 'Soothing Honey Chamomile Nightcap Tea',
          type: 'Soothing Drink',
          description:
              'Whole dried chamomile blossoms steeped in boiling water for 7 minutes, sweetened with raw honey. Ideal right before bed when cramps threaten sleep.',
          quickTip: 'Cover the cup while steeping to prevent calming essential oils from evaporating.',
        ),
        FoodDish(
          name: 'Warm Fresh Peppermint Stomach Calmer',
          type: 'Soothing Drink',
          description:
              'Fresh crushed peppermint leaves steeped in hot water with a slice of fresh lemon. Swiftly relieves abdominal fullness, gas, and digestive cramping.',
          quickTip: 'Naturally 100% caffeine-free so it will not constrict blood vessels.',
        ),
        FoodDish(
          name: 'Spiced Chamomile Vanilla Oat Latte',
          type: 'Warm Comfort Treat',
          description:
              'Double-strength chamomile tea topped with frothed warm oat milk, pure vanilla extract, and a dust of nutmeg. Cozy coffeehouse comfort without caffeine.',
          quickTip: 'Frothed oat milk provides a luxurious creamy texture without dairy.',
        ),
      ],
    ),

    // 8. Almonds, Pumpkin Seeds & Walnuts
    FoodSuggestion(
      id: 'nuts_seeds',
      name: 'Almonds, Pumpkin Seeds & Walnuts',
      icon: Icons.grain_outlined,
      category: FoodCategory.ironEnergy,
      keyNutrient: 'Zinc, Vitamin E, Magnesium & Healthy Fats',
      benefit: 'Reduces prostaglandins, relieves breast tenderness, and provides sustained stamina.',
      whyItHelpsOnRedDays:
          'Pumpkin seeds are exceptionally rich in zinc, which clinical studies have linked to shorter, less painful period cycles. Vitamin E in almonds stabilizes cell membranes and relieves cyclical breast pain and bloating.',
      clinicalSource: 'PubMed / Journal of Research in Medical Sciences & NHS (UK)',
      clinicalEvidence:
          'A randomized double-blind clinical trial demonstrated that oral zinc intake reduces menstrual pain severity by inhibiting inflammatory cyclooxygenase enzyme activity and improving pelvic microcirculation. NHS guidelines note Vitamin E reduces mastalgia (breast tenderness).',
      scientificReference:
          'Teimoori B, et al. The efficacy of zinc administration on primary dysmenorrhea: A randomized double-blind trial. J Res Med Sci. 2016; Ziaei S, et al. BJOG. 2005.',
      allergenTags: ['nuts'],
      cravingTags: ['healthy_fats', 'comfort', 'sweets'],
      dishes: [
        FoodDish(
          name: 'Honey Cinnamon Roasted Spiced Nuts',
          type: 'Crunchy Snack',
          description:
              'Raw almonds, pumpkin seeds, and walnut halves tossed in melted coconut oil, sea salt, cinnamon, and honey, roasted until golden and fragrant.',
          quickTip: 'Roasting brings out natural oils and makes minerals easier to digest.',
        ),
        FoodDish(
          name: 'Toasted Almond Butter Banana Toast',
          type: 'Warm Snack',
          description:
              'Warm toasted bread spread generously with creamy almond butter, layered with sliced banana, a drizzle of honey, and toasted pumpkin seeds.',
          quickTip: 'Combines magnesium, potassium, and healthy fats in one comforting bite.',
          safeSubstitute: 'If allergic to tree nuts, swap almond butter for sunflower seed butter (nut-free).',
        ),
      ],
    ),

    // 9. Sweet Potatoes & Warm Squash
    FoodSuggestion(
      id: 'sweet_potatoes',
      name: 'Sweet Potatoes & Warm Squash',
      icon: Icons.soup_kitchen_outlined,
      category: FoodCategory.moodComfort,
      keyNutrient: 'Beta-Carotene (Vitamin A), Potassium & Slow Carbs',
      benefit: 'Calms sweet and salty cravings with low-glycemic satiety while relieving cramps with potassium.',
      whyItHelpsOnRedDays:
          'Warm, grounding root vegetables nourish the body with sustained slow-digesting carbohydrates, preventing irritability and sugar binge crashes while delivering abundant potassium and dietary fiber.',
      clinicalSource: 'Harvard T.H. Chan School of Public Health',
      clinicalEvidence:
          'Harvard nutritional research highlights sweet root vegetables as optimal low-glycemic sources of fiber and beta-carotene that mitigate hormone-driven insulin resistance and prevent postprandial glucose volatility associated with mood instability.',
      scientificReference:
          'Harvard T.H. Chan School of Public Health: Carbohydrates, Glycemic Index and Women\'s Health; USDA FoodData Central.',
      allergenTags: [],
      cravingTags: ['comfort', 'warm_soups', 'pasta_rice', 'sweets'],
      dishes: [
        FoodDish(
          name: 'Roasted Cinnamon Honey Sweet Potato Wedges',
          type: 'Warm Comfort Snack',
          description:
              'Thick sweet potato wedges roasted in olive oil with ground cinnamon and sea salt, drizzled with honey while still sizzling hot.',
          quickTip: 'Bake at 200°C (400°F) for 25 minutes until caramelized and tender.',
        ),
        FoodDish(
          name: 'Cozy Coconut Sweet Potato Curry',
          type: 'Warm Meal',
          description:
              'Diced sweet potatoes simmered in coconut milk with turmeric, spinach, ginger, and chickpeas, served over warm fluffy rice.',
          quickTip: 'Combines sweet potato comfort with turmeric anti-inflammatory power.',
          safeSubstitute: 'Naturally vegan, gluten-free, dairy-free, and nut-free.',
        ),
        FoodDish(
          name: 'Fluffy Mashed Sweet Potatoes with Butter',
          type: 'Cozy Side',
          description:
              'Steamed sweet potatoes mashed smooth with a pat of butter (or coconut oil), sea salt, and a hint of nutmeg.',
          quickTip: 'Warm, soothing, and effortless to digest on days when appetite is delicate.',
        ),
      ],
    ),

    // 10. Fresh Berries & Citrus
    FoodSuggestion(
      id: 'berries_citrus',
      name: 'Fresh Berries & Citrus',
      icon: Icons.brightness_5_outlined,
      category: FoodCategory.antiBloat,
      keyNutrient: 'Anthocyanins, Vitamin C & Hydration',
      benefit: 'Combats systemic inflammation and dramatically boosts plant-based iron absorption.',
      whyItHelpsOnRedDays:
          'Anthocyanins in blueberries and blackberries inhibit inflammatory cyclooxygenase enzymes. The high vitamin C content is crucial when consumed with greens or grains to convert non-heme iron into readily absorbable ferrous form.',
      clinicalSource: 'PubMed / Nutrients & American Journal of Clinical Nutrition',
      clinicalEvidence:
          'Clinical nutritional studies establish that co-ingesting ascorbic acid (Vitamin C) with non-heme dietary iron overcomes food inhibitors (phytates, polyphenols) and multiplies iron bioavailability by up to 300%. Anthocyanins reduce systemic CRP and TNF-alpha inflammatory markers.',
      scientificReference:
          'Lynch SR, Cook JD. Interaction of vitamin C and iron. Ann N Y Acad Sci.; Cassidy A, et al. Dietary flavonoids and inflammatory markers in women. Am J Clin Nutr.',
      allergenTags: [],
      cravingTags: ['berries', 'sweets', 'tea'],
      dishes: [
        FoodDish(
          name: 'Warm Mixed Berry Crumble with Oat Crust',
          type: 'Warm Sweet Treat',
          description:
              'Blueberries and raspberries baked under a crisp golden topping of rolled oats, cinnamon, and maple syrup. Served bubbling hot.',
          quickTip: 'Bake for 20 minutes until berries burst into a sweet compote.',
          safeSubstitute: 'Naturally dairy-free and gluten-free when using GF oats.',
        ),
        FoodDish(
          name: 'Greek Yogurt Berry Parfait with Honey',
          type: 'Fresh Snack',
          description:
              'Thick probiotic yogurt layered with fresh berries, pumpkin seeds, and a spiral of honey to nourish gut flora and settle bloating.',
          quickTip: 'Probiotics help alleviate period-related digestive irregularity.',
          safeSubstitute: 'Use coconut or almond milk yogurt if avoiding dairy.',
        ),
      ],
    ),

    // 11. Turmeric & Golden Spices
    FoodSuggestion(
      id: 'turmeric_spices',
      name: 'Turmeric & Golden Milk',
      icon: Icons.flare_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'Curcumin (Potent Natural Anti-inflammatory)',
      benefit: 'Down-regulates NF-kB and COX-2 inflammatory enzymes in the pelvic reproductive tract.',
      whyItHelpsOnRedDays:
          'Curcumin is one of nature\'s most thoroughly researched anti-inflammatory compounds. In randomized double-blind clinical trials, daily curcumin significantly reduced the severity of premenstrual and menstrual symptom scores.',
      clinicalSource: 'PubMed / Complementary Therapies in Medicine',
      clinicalEvidence:
          'In a randomized, double-blind, placebo-controlled trial, women receiving oral curcumin capsules starting 7 days prior to menses through 3 days post-onset had statistically significant decreases in PMS behavioral, mood, and pelvic pain scores compared to placebo.',
      scientificReference:
          'Khayat S, Kheirkhah M, Behboodi Moghadam Z, et al. Curcumin attenuates severity of premenstrual syndrome symptoms: A randomized, double-blind, placebo-controlled trial. Complement Ther Med. 2015.',
      allergenTags: [],
      cravingTags: ['tea', 'warm_soups', 'comfort'],
      dishes: [
        FoodDish(
          name: 'Warm Golden Turmeric Milk (Haldi Doodh)',
          type: 'Soothing Drink',
          description:
              'Warm oat milk whisked with ground turmeric, cinnamon, crushed black pepper, fresh ginger, and pure maple syrup. A deeply soothing evening ritual.',
          quickTip: 'Black pepper contains piperine, which boosts curcumin absorption by 2000%.',
          safeSubstitute: 'Naturally 100% dairy-free with oat, soy, or coconut milk.',
        ),
        FoodDish(
          name: 'Golden Turmeric Red Lentil Dahl',
          type: 'Warm Meal',
          description:
              'Red lentils gently simmered with turmeric, cumin, ginger, and coconut milk into a rich, fragrant stew. High in iron, protein, and anti-inflammatory compounds.',
          quickTip: 'Serve over basmati rice with a squeeze of fresh lime.',
        ),
      ],
    ),

    // 12. Lentils & Chickpeas
    FoodSuggestion(
      id: 'lentils_legumes',
      name: 'Lentils & Chickpeas (Legumes)',
      icon: Icons.grain_rounded,
      category: FoodCategory.ironEnergy,
      keyNutrient: 'Plant Iron, Folate, Zinc & Fiber',
      benefit: 'Steadies energy and replaces blood mineral losses without saturated fats.',
      whyItHelpsOnRedDays:
          'Lentils provide one of the highest plant-based iron concentrations per cup, alongside complex fiber that binds to excess circulating estrogen in the gut for smooth hormonal balance.',
      clinicalSource: 'WHO (World Health Organization) & Cleveland Clinic',
      clinicalEvidence:
          'WHO dietary guidelines for women of reproductive age highlight pulses and legumes as premier sources of non-heme iron and folate to replenish hemoglobin and maintain erythropoiesis during monthly blood loss without the high saturated fat content of red meats.',
      scientificReference:
          'WHO Guidelines on Healthy Diet & Micronutrient Balance for Women of Reproductive Age; Cleveland Clinic: Nutrition Strategies for Menstrual Health.',
      allergenTags: [],
      cravingTags: ['warm_soups', 'comfort', 'pasta_rice'],
      dishes: [
        FoodDish(
          name: 'Warm Mediterranean Chickpea & Tomato Stew',
          type: 'Warm Comfort Meal',
          description:
              'Tender chickpeas braised in crushed plum tomatoes, garlic, extra virgin olive oil, and fresh oregano. Rich in iron and lycopene.',
          quickTip: 'Pair with warm crusty bread for a deeply grounding dinner.',
        ),
        FoodDish(
          name: 'Creamy Garlic Hummus with Warm Pita & Veggies',
          type: 'Quick Snack',
          description:
              'Whipped chickpea tahini hummus with olive oil, served with toasted pita triangles and cucumber slices for savory craving satisfaction.',
          quickTip: 'High in zinc, protein, and magnesium.',
        ),
      ],
    ),

    // 13. Pasteurized Low-Sodium Cheese (WHO & ACOG Calcium Guidelines)
    FoodSuggestion(
      id: 'cheese_calcium',
      name: 'Cheese (Ricotta, Mozzarella & Cottage Cheese)',
      icon: Icons.local_pizza_outlined,
      category: FoodCategory.crampRelief,
      keyNutrient: 'Bioavailable Calcium, Vitamin D, B12 & Tryptophan',
      benefit: 'Regulates uterine smooth muscle tone to reduce menstrual cramps and PMS mood swings.',
      whyItHelpsOnRedDays:
          'Drops in extracellular calcium during the luteal and menstrual phases trigger neuromuscular hyper-excitability and uterine spasms. Pasteurized, low-sodium cheeses (such as fresh mozzarella, ricotta, cottage cheese, and Swiss) deliver dense bioavailable calcium, Vitamin D, and tryptophan while respecting WHO low-sodium guidelines to prevent water retention.',
      clinicalSource: 'WHO (World Health Organization) & ACOG Guidelines',
      clinicalEvidence:
          'WHO micronutrient guidelines for women of reproductive age and ACOG Practice Bulletins recommend 1,000–1,200 mg daily calcium intake. Multicenter randomized double-blind trials demonstrate that adequate calcium and Vitamin D reduce menstrual pain, cramping, and PMS symptoms by up to 48%, while WHO sodium guidelines (<2g/day) advise choosing low-sodium fresh or Swiss cheeses.',
      scientificReference:
          'WHO Guideline: Calcium and Sodium Intake for Adults and Women of Reproductive Age (World Health Organization, Geneva); Thys-Jacobs S, et al. Am J Obstet Gynecol. 1998; Bertone-Johnson ER, et al. Arch Intern Med. 2005.',
      allergenTags: ['dairy'],
      cravingTags: ['cheese', 'comfort', 'pasta_rice', 'sweets'],
      dishes: [
        FoodDish(
          name: 'Warm Baked Ricotta, Honey & Berry Toast',
          type: 'Warm Comfort Treat',
          description:
              'Creamy low-sodium ricotta cheese spread thick over warm toasted sourdough, topped with warm berries and a drizzle of raw honey.',
          quickTip: 'Ricotta is naturally low in sodium and rich in whey protein and bioavailable calcium.',
          safeSubstitute: 'Use whipped almond or cashew ricotta if dairy-allergic.',
        ),
        FoodDish(
          name: 'Comforting Spinach & Three-Cheese Baked Pasta',
          type: 'Warm Comfort Meal',
          description:
              'Tender pasta baked with fresh mozzarella, ricotta, and wilted baby spinach in a garlic-tomato sauce. Combines WHO-recommended iron from greens with cramp-relieving calcium.',
          quickTip: 'Pair with a side salad dressed in lemon juice to boost iron absorption.',
          safeSubstitute: 'Use gluten-free pasta and plant-based mozzarella for allergy safety.',
        ),
        FoodDish(
          name: 'Whipped Cottage Cheese & Warm Cinnamon Apple Bowl',
          type: 'Quick Snack',
          description:
              'High-protein cultured cottage cheese topped with warm cinnamon-sautéed apple slices and pumpkin seeds for steady blood sugar and muscle relaxation.',
          quickTip: 'Cultured cottage cheese is low in lactose and gentle on digestion.',
          safeSubstitute: 'Swap cottage cheese for thick coconut yogurt if lactose-intolerant.',
        ),
        FoodDish(
          name: 'Warm Fresh Mozzarella, Tomato & Basil Melt (Caprese)',
          type: 'Warm Snack',
          description:
              'Melted fresh mozzarella layered with ripe tomato slices, fresh basil leaves, and extra virgin olive oil on toasted whole-grain bread.',
          quickTip: 'Fresh mozzarella has significantly less salt than aged processed cheeses, aligning with WHO sodium limits.',
        ),
      ],
    ),
  ];

  static List<FoodSuggestion> getFilteredSuggestions({
    List<String> userAllergies = const [],
    List<String> userCravings = const [],
    FoodCategory? category,
    String? searchQuery,
    bool safeOnly = false,
  }) {
    return allSuggestions.where((item) {
      // 1. Category filter
      if (category != null && item.category != category) {
        return false;
      }

      // 2. Allergen filter if safeOnly is true
      if (safeOnly && item.hasAllergen(userAllergies)) {
        return false;
      }

      // 3. Search query
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.toLowerCase().trim();
        final matchesName = item.name.toLowerCase().contains(query);
        final matchesNutrient = item.keyNutrient.toLowerCase().contains(query);
        final matchesBenefit = item.benefit.toLowerCase().contains(query);
        final matchesSource = item.clinicalSource.toLowerCase().contains(query);
        final matchesDishes = item.dishes.any((d) =>
            d.name.toLowerCase().contains(query) ||
            d.description.toLowerCase().contains(query));
        if (!matchesName &&
            !matchesNutrient &&
            !matchesBenefit &&
            !matchesSource &&
            !matchesDishes) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Prioritize items matching user cravings to the top
        final aMatchesCraving = a.matchesCravings(userCravings);
        final bMatchesCraving = b.matchesCravings(userCravings);
        if (aMatchesCraving && !bMatchesCraving) return -1;
        if (!aMatchesCraving && bMatchesCraving) return 1;

        // Next, prioritize allergen-safe items
        final aHasAllergen = a.hasAllergen(userAllergies);
        final bHasAllergen = b.hasAllergen(userAllergies);
        if (!aHasAllergen && bHasAllergen) return -1;
        if (aHasAllergen && !bHasAllergen) return 1;

        return 0;
      });
  }
}
