const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  const { district } = req.query;
  res.json({
    district: district || 'Murshidabad',
    courses: [
      { title: 'Digital Office Assistant', provider: 'NSDC Training Partner', distanceKm: 4.2, freeGiaFunded: true },
      { title: 'Data Entry Operator', provider: 'Pradhan Mantri Kaushal Kendra', distanceKm: 7.8, freeGiaFunded: true, seatsLeft: 3 },
      { title: 'Retail Sales Associate', provider: 'SSDM West Bengal', distanceKm: 11.3, freeGiaFunded: true },
    ],
  });
});

module.exports = router;
